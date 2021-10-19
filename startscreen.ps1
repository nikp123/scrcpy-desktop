param($Resolution, $DPI)

$KEYBOARD_PACKAGE="com.wparam.nullkeyboard"

# Functions go here
function enable_desktop_mode {
	echo "This device doesn't have desktop mode enabled!!!!"
	echo "This will require enabling said option (done automatically)"
	echo "However for it to apply, your device needs to restart"
	pause

	.\bin\adb.exe shell settings put global force_desktop_mode_on_external_displays 1
	.\bin\adb.exe shell settings put global force_allow_on_external 1
	echo "Enabled desktop mode"

	# Prevents a bug where the display shows up before this option is enabled properly
	.\bin\adb.exe shell settings put global overlay_display_devices none

	# Just to make sure that everything's written to disk before the forced reboot
	.\bin\adb.exe shell sync
	sleep 2

	# You need to reboot aparently for it to apply
	.\bin\adb.exe reboot
	echo "Rebooting..."

	# Wait for it to reappear
	.\bin\adb.exe wait-for-device
	echo "Waiting for the device to respond"

	# Wait for the services to initialize
	sleep 20
}

function host_sanity_check {
	# Check if all the executables are present on the host device
	$BINlist = "adb,scrcpy"
	$BINlist = $BINlist.split(",");
	foreach ($i in $BINlist) {
		if (!(Test-Path "bin\$i.exe")) {
			throw "$i is missing. Are you sure you downloaded scrcpy?"
		}
	}
}

function target_sanity_check {
	# Check Android version
	if ( [string](.\bin\adb.exe shell getprop ro.build.version.sdk) -lt 29 ) {
		throw "Sorry, desktop mode is only supported on Android 10 and up."
	}

	# Check if all the executables are present on the target device
	$BINlist = "sh,ps,grep"
	$BINlist = $BINlist.split(",");
	foreach ($i in $BINlist) {
		$output = [string](.\bin\adb.exe shell which $i)
		if ($? -eq 0) {
			throw "Your Android device is missing '$i' and this script won't work without it. Sorry..."
		}
	}

	if ( !([string](.\bin\adb.exe shell "pm list package | grep $KEYBOARD_PACKAGE"))) {
		echo "Null keyboard not installed. Please install it so we can hide the"
		echo "keyboard while in desktop mode!"
		echo ""
		echo "App link: https://play.google.com/store/apps/details?id=$KEYBOARD_PACKAGE"
		echo "After installing the app, we can continue..."
		pause
	}
}

$TARGET_TMP_DIR = "/data/local/tmp"
$TARGET_SCRIPT1 = "$TARGET_TMP_DIR/scrcpy-payload1.sh"
$TARGET_SCRIPT2 = "$TARGET_TMP_DIR/scrcpy-payload2.sh"

# Check if host is capable
host_sanity_check

# Wait for the device before the script does anything
echo "Waiting for a device..."
.\bin\adb.exe wait-for-device

# Checks if the target device is capable
target_sanity_check

# Change secondary display behaviour
.\bin\adb shell settings put global enable_freeform_support 1
.\bin\adb shell settings put global force_resizable_activities 1

# Check if desktop mode is already enabled, if not, prompt the user and do the
# required steps
$result=[string](.\bin\adb.exe shell settings get global force_desktop_mode_on_external_displays)
if ($result -eq 0) {
	enable_desktop_mode
}
$result=[string](.\bin\adb.exe shell settings get global force_allow_on_external)
if ($result -eq 0) {
	enable_desktop_mode
}

# I'm not making this a function because powershell sucks
if ( $Resolution -eq $null ) {
	echo "Automatic screen resolution doesnt work thanks to powershell being bad"
	$RESOLUTION="1920x1080"
} else {
	$RESOLUTION=$Resolution
}

if ( $DPI -eq $null ) {
	echo "Automatic screen dpi doesnt work thanks to powershell being bad"
	$DENSITY=120 # go with the default, as windows doesn't have this feature yet ;(
} else {
	$DENSITY=$DPI
}

$TARGET_DISPLAY_MODE=[string](echo $RESOLUTION/$DENSITY)

# Use the secondary screen option to generate the other screen
.\bin\adb.exe shell settings put global overlay_display_devices $TARGET_DISPLAY_MODE

# Wait for the display to appear
sleep 1

# Do your magic
$display_fetch_cmd = 'dumpsys display | grep \"  Display \" | cut -d\" \" -f4 | grep -v "0:" | sed -e \"s/://\"'
$display=[string](.\bin\adb.exe shell "$display_fetch_cmd")

## if fetching fails, try defaults
if ( "$display" -eq "" ) {
	echo "Host system has incompatible settings. Sorry about that."

	# Screen res/DPI (doesn't accept all values unfortunately)
	$TARGET_DISPLAY_MODE="1920x1080/120"

	# Use the secondary screen option to generate the other screen
	.\bin\adb.exe shell settings put global overlay_display_devices $TARGET_DISPLAY_MODE

	# Wait for the display to appear
	sleep 1

	# Do your magic
	$display=[string](.\bin\adb.exe shell "$display_fetch_cmd")
}

# use -S if you're edgy
$SCRCPY_PROC = Start-Process -NoNewWindow -FilePath ".\bin\scrcpy.exe" -PassThru -ArgumentList @('--display', "$display", '-w')

# Bash let me down so this is the alternative I have to work with
$SCRCPY_PID = $SCRCPY_PROC.ID

#
# Payload section starts here
#

# Execute the payload stream generator remotely (with precisely the parameters that it wants)
.\bin\adb.exe push payload/stage1.sh $TARGET_SCRIPT1
.\bin\adb.exe push payload/stage2.sh $TARGET_SCRIPT2
.\bin\adb.exe shell chmod +x $TARGET_SCRIPT1
.\bin\adb.exe shell chmod +x $TARGET_SCRIPT2
Start-Process -NoNewWindow -FilePath ".\bin\adb.exe" -ArgumentList @('shell', "$TARGET_SCRIPT1")

# Add disclaimer
echo "-----------------------------------------------------"
echo "|                                                   |"
echo "|  Please unlock the phone once the screen appears  |"
echo "|                                                   |"
echo "-----------------------------------------------------"

# Because wait is broken, I'm using this
Wait-Process -Id $SCRCPY_PID

exit 0
