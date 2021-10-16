#!/bin/bash

TARGET_TMP_DIR=/data/local/tmp
TARGET_SCRIPT1=$TARGET_TMP_DIR/scrcpy-payload1.sh
TARGET_SCRIPT2=$TARGET_TMP_DIR/scrcpy-payload2.sh

# Screen res/DPI (doesn't accept all values unfortunately)
TARGET_DISPLAY_MODE=1920x1080/120

# Wait for the device before the script does anything
adb wait-for-device

# Change secondary display behaviour
adb shell settings put global enable_freeform_support 1
adb shell settings put global force_desktop_mode_on_external_displays 1
adb shell settings put global force_resizable_activities 1

# Use the secondary screen option to generate the other screen
adb shell settings put global overlay_display_devices $TARGET_DISPLAY_MODE

# You need to reboot aparently for it to apply
adb reboot

# Wait for it to reappear
adb wait-for-device

# Wait for the services to initialize
sleep 20

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
