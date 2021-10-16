#!/bin/bash

# Functions go here
function enable_desktop_mode {
	echo "This device doesn't have desktop mode enabled!!!!"
	echo "This will require enabling said option (done automatically)"
	echo "However for it to apply, your device needs to restart"
	read -p "Press any key restart your phone and continue with this script"

	adb shell settings put global force_desktop_mode_on_external_displays 1
	echo "Enabled desktop mode"

	# Prevents a bug where the display shows up before this option is enabled properly
	adb shell settings put global overlay_display_devices none

	# Just to make sure that everything's written to disk before the forced reboot
	adb shell sync
	sleep 2

	# You need to reboot aparently for it to apply
	adb reboot
	echo "Rebooting..."

	# Wait for it to reappear
	adb wait-for-device
	echo "Waiting for the device to respond"

	# Wait for the services to initialize
	sleep 20
}

function host_sanity_check {
	# Check if all the executables are present on the host device
	for i in adb scrcpy tail pgrep; do
		which $i >/dev/null 2>&1
		[[ $? -ne 0 ]] && \
			echo "Please download $i and add it into your path before running this script." && \
			exit 1
	done
}

function target_sanity_check {
	[[ $(adb shell getprop ro.build.version.sdk) < 29 ]] && \
		echo "Sorry, desktop mode is only supported on Android 10 and up." && \
		exit 1

	# Check if all the executables are present on the target device
	for i in sh ps grep; do
		adb shell which $i >/dev/null 2>&1
		[[ $? -ne 0 ]] && \
			echo "Your Android device is missing '$i' and this script won't work without it. Sorry..." && \
			exit 1
	done
}

function get_display_params {
	if [[ -z $2 ]]; then
		RESOLUTION=$(xdpyinfo | grep dimensions | cut -d' ' -f 7)
	else
		RESOLUTION=$2
	fi

	if [[ -z $3 ]]; then
		DENSITY=$(echo "$(xdpyinfo | grep resolution | cut -d' ' -f 7 | cut -d'x' -f 1)*1.33333337" | bc | cut -d'.' -f 1)
	else
		DENSITY=$3
	fi

	TARGET_DISPLAY_MODE=$(echo $RESOLUTION/$DENSITY)
}

TARGET_TMP_DIR=/data/local/tmp
TARGET_SCRIPT1=$TARGET_TMP_DIR/scrcpy-payload1.sh
TARGET_SCRIPT2=$TARGET_TMP_DIR/scrcpy-payload2.sh

# Screen res/DPI (doesn't accept all values unfortunately)
TARGET_DISPLAY_MODE=1920x1080/120

# Check if host is capable
host_sanity_check

# Wait for the device before the script does anything
adb wait-for-device

# Checks if the target device is capable
target_sanity_check

# Change secondary display behaviour
adb shell settings put global enable_freeform_support 1
adb shell settings put global force_resizable_activities 1

# Check if desktop mode is already enabled, if not, prompt the user and do the
# required steps
result=$(adb shell settings get global force_desktop_mode_on_external_displays)
if [ "$result" == "0" ]; then
	enable_desktop_mode
fi

get_display_params
echo $TARGET_DISPLAY_MODE

# Use the secondary screen option to generate the other screen
adb shell settings put global overlay_display_devices $TARGET_DISPLAY_MODE

# Wait for the display to appear
sleep 1

# Do your magic
display=$(adb shell dumpsys display | grep "  Display " | cut -d' ' -f4 | grep -v "0:" | sed -e 's/://')

# use -S if you're edgy
scrcpy --display $display -w &

# Bash let me down so this is the alternative I have to work with
SCRCPY_PID=$(pgrep scrcpy)

#
# Payload section starts here
#

# Execute the payload stream generator remotely (with precisely the parameters that it wants)
adb push payload/stage1.sh $TARGET_SCRIPT1
adb push payload/stage2.sh $TARGET_SCRIPT2
adb shell chmod +x $TARGET_SCRIPT1
adb shell chmod +x $TARGET_SCRIPT2
# Mute the script as it does produce a lot of garbage
adb shell $TARGET_SCRIPT1 &> /dev/null &

# Add disclaimer
echo "-----------------------------------------------------"
echo "|                                                   |"
echo "|  Please unlock the phone once the screen appears  |"
echo "|                                                   |"
echo "-----------------------------------------------------"

# Because wait is broken, I'm using this
echo SCRCPY PID: $SCRCPY_PID
tail --pid=$SCRCPY_PID -f /dev/null

exit 0
