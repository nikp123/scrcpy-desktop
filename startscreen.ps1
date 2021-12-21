param($Resolution, $DPI)

$LAUNCHER_PACKAGE = "com.farmerbb.taskbar"
$KEYBOARD_PACKAGE = "com.wparam.nullkeyboard"
$SCRIPT_NAME = $MyInvocation.MyCommand.Name 

# By default get adb and scrcpy paths from special bin folder, like in older versions of this script.
# It can be overwritten in host_sanity_check function in situations where binary isn't located in bin folder, but is
# found somewhere in $PATH enviroment variable
$PATHS = @{}


# Functions go here
function echowrapper($str) {
	Write-Output "[ $SCRIPT_NAME ]: $str"
}

function enable_desktop_mode {
	echowrapper "This device doesn't have desktop mode enabled!!!!"
	echowrapper "This will require enabling said option (done automatically)"
	echowrapper "However for it to apply, your device needs to restart"
	pause

	& $PATHS.adb shell "settings put global force_desktop_mode_on_external_displays 1"
	& $PATHS.adb shell "settings put global force_allow_on_external 1"
	echowrapper "Enabled desktop mode"

	# Prevents a bug where the display shows up before this option is enabled properly
	& $PATHS.adb shell "settings put global overlay_display_devices none"

	# Just to make sure that everything's written to disk before the forced reboot
	& $PATHS.adb shell "sync"
	Start-Sleep 2

	# You need to reboot aparently for it to apply
	& $PATHS.adb reboot
	echowrapper "Rebooting..."

	# Wait for it to reappear
	& $PATHS.adb wait-for-device
	echowrapper "Waiting for the device to respond"

	# Wait for the services to initialize
	Start-Sleep 20
}

function host_sanity_check {
	# Check if all the executables are present on the host device
	$BINlist = "adb,scrcpy"
	$BINlist = $BINlist.split(",");
	foreach ($i in $BINlist) {
		if ((Test-Path "bin\$i.exe")) {
			echowrapper "Binary ($i) found in bin folder."
			$PATHS.Add($i, "bin\$i.exe")
		}
		else {
			echowrapper "Binary ($i) was not found in bin folder. Searching in `$PATH ..."
			try {
				$temp_path = (Get-Command -ErrorAction Stop $i).Path
				echowrapper "Binary ($i) was found in $temp_path"
				$PATHS.Add($i, $temp_path )
			}
			catch {
				echowrapper "Binary ($i) is missing in `$PATH also. Are you sure you downloaded $($i)?"
				throw "Missing binary error"
			}
		}
	}
}

function target_sanity_check {
	# Check Android version
	if ( [string](& $PATHS.adb shell "getprop ro.build.version.sdk") -lt 29 ) {
		throw "Sorry, desktop mode is only supported on Android 10 and up." 
		# Most of the times scrcpy sees just black screen instead of virtual display so it may sill not work on android 10
	}

	# Check if all the executables are present on the target device
	$BINlist = "sh,ps,grep"
	$BINlist = $BINlist.split(",");
	foreach ($i in $BINlist) {
		$output = [string](& $PATHS.adb shell "which $i")
		if ("$output" -eq "") {
			throw "Your Android device is missing '$i' and this script won't work without it. Sorry..."
		}
	}

	if ( !([string](& $PATHS.adb shell "pm list package | grep $KEYBOARD_PACKAGE"))) {
		echowrapper "Null keyboard not installed. Please install it so we can hide the"
		echowrapper "keyboard while in desktop mode!"
		echowrapper ""
		echowrapper "App link: https://play.google.com/store/apps/details?id=$KEYBOARD_PACKAGE"
		echowrapper "After installing the app, we can continue..."
		# It seams that null keyboard was pulled from playstore so it may not work.
		& $PATHS.adb shell am start -a android.intent.action.VIEW -d "market://details?id=$KEYBOARD_PACKAGE"
		pause
	}
	
	if ( !([string](& $PATHS.adb shell "pm list package | grep $LAUNCHER_PACKAGE"))) {
		echowrapper "Taskbar not installed, please install it so that you wouldn't end"
		echowrapper "up in a situation where the launcher is not installed"
		echowrapper "https://github.com/nikp123/scrcpy-desktop/issues/7"
		echowrapper
		echowrapper "App link: https://play.google.com/store/apps/details?id=$LAUNCHER_PACKAGE"
		echowrapper "After installing the app, we can continue..."
		& $PATHS.adb shell am start -a android.intent.action.VIEW -d "market://details?id=$LAUNCHER_PACKAGE"
		pause
	}
}

$TARGET_TMP_DIR = "/data/local/tmp"
$TARGET_SCRIPT1 = "$TARGET_TMP_DIR/scrcpy-payload1.sh"
$TARGET_SCRIPT2 = "$TARGET_TMP_DIR/scrcpy-payload2.sh"

# Check if host is capable
host_sanity_check

# Wait for the device before the script does anything
echowrapper "Waiting for a device..."
& $PATHS.adb wait-for-device

# Checks if the target device is capable
target_sanity_check

# Change secondary display behaviour
& $PATHS.adb shell "settings put global enable_freeform_support 1"
& $PATHS.adb shell "settings put global force_resizable_activities 1"

# Check if desktop mode is already enabled, if not, prompt the user and do the
# required steps
$result = [string](& $PATHS.adb shell "settings get global force_desktop_mode_on_external_displays")
if ($result -eq 0) {
	enable_desktop_mode
}
$result = [string](& $PATHS.adb shell "settings get global force_allow_on_external")
if ($result -eq 0) {
	enable_desktop_mode
}

# I'm not making this a function because powershell sucks
if ( $null -eq $Resolution ) {
	echowrapper "Automatic screen resolution doesnt work thanks to powershell being bad"
	$RESOLUTION = "1920x1080"
}
else {
	$RESOLUTION = $Resolution
}

if ( $null -eq $DPI ) {
	echowrapper "Automatic screen dpi doesnt work thanks to powershell being bad"
	$DENSITY = 240 # go with the default, as windows doesn't have this feature yet ;(
}
else {
	$DENSITY = $DPI
}

$TARGET_DISPLAY_MODE = "$RESOLUTION`/$DENSITY"

# Use the secondary screen option to generate the other screen
& $PATHS.adb shell "settings put global overlay_display_devices $TARGET_DISPLAY_MODE"

# Wait for the display to appear
Start-Sleep 1

# Do your magic
$display_fetch_cmd = 'dumpsys display | grep \"  Display \" | cut -d\" \" -f4 | grep -v "0:" | sed -e \"s/://\"'
$display = [string](& $PATHS.adb shell "$display_fetch_cmd")

## if fetching fails, try defaults
if ( "$display" -eq "" ) {
	echowrapper "Host system has incompatible settings. Sorry about that."

	# Screen res/DPI (doesn't accept all values unfortunately)
	$TARGET_DISPLAY_MODE = "1920x1080/240"

	# Use the secondary screen option to generate the other screen
	& $PATHS.adb shell "settings put global overlay_display_devices $TARGET_DISPLAY_MODE"

	# Wait for the display to appear
	Start-Sleep 1

	# Do your magic
	$display = [string](& $PATHS.adb shell "$display_fetch_cmd")
}

# use -S if you're edgy
$SCRCPY_PROC = Start-Process -NoNewWindow -FilePath $PATHS.scrcpy -PassThru -ArgumentList @('--display', "$display", '-w')

# Bash let me down so this is the alternative I have to work with
$SCRCPY_PID = $SCRCPY_PROC.ID

#
# Payload section starts here
#

# Execute the payload stream generator remotely (with precisely the parameters that it wants)
& $PATHS.adb push payload/stage1.sh $TARGET_SCRIPT1
& $PATHS.adb push payload/stage2.sh $TARGET_SCRIPT2
& $PATHS.adb shell chmod +x $TARGET_SCRIPT1
& $PATHS.adb shell chmod +x $TARGET_SCRIPT2
Start-Process -NoNewWindow -FilePath $PATHS.adb -ArgumentList shell, $TARGET_SCRIPT1

# Add disclaimer
echowrapper "-----------------------------------------------------"
echowrapper "|                                                   |"
echowrapper "|  Please unlock the phone once the screen appears  |"
echowrapper "|                                                   |"
echowrapper "-----------------------------------------------------"

# Because wait is broken, I'm using this
Wait-Process -Id $SCRCPY_PID

exit 0
