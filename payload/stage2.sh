#!/system/bin/sh

NULL_KEYBOARD=com.wparam.nullkeyboard/.NullKeyboard
DEFAULT_KEYBOARD=$(settings get secure default_input_method)

echo "Default keyboard detected as: $DEFAULT_KEYBOARD"

# Set the NULL keyboard
ime enable $NULL_KEYBOARD
ime set $NULL_KEYBOARD

# Where's my fucking UNIX degree already
while ps -Afo PID,ARGS=CMD | grep scrcpy-server.jar | grep -v grep 2>&1 >/dev/null ; do
	sleep 1
done

# Destroy the other screen as it is no longer needed
settings delete global overlay_display_devices

# (Hopefully) Restore sane defaults
# settings put global enable_freeform_support 0
# settings put global force_resizable_activities 0

# Restore old keyboard
ime disable $NULL_KEYBOARD
ime set $DEFAULT_KEYBOARD

