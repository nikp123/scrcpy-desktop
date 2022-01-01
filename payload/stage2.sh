#!/system/bin/sh

FILE=$1
INTERVAL=$2

function echowrapper() {
	log -t payload2 $*
}

NULL_KEYBOARD=com.wparam.nullkeyboard/.NullKeyboard
DEFAULT_KEYBOARD=$(settings get secure default_input_method)

echowrapper "Default keyboard detected as: $DEFAULT_KEYBOARD"

# Set the NULL keyboard
echowrapper `ime enable $NULL_KEYBOARD`
echowrapper `ime set $NULL_KEYBOARD`

MAX_RETRY_COUNT=3
current_try=0
old_nr=`cat $FILE`

# Check if the given file was changed recently. If not then stop checking and reset settings to the defaults.
while [ true ]; do
	nr=`cat $FILE`

	if [ $nr -eq $old_nr ]; then
		if [ $current_try -eq $MAX_RETRY_COUNT ]; then
			echowrapper "Same value as before for $current_try time (ending...)"
			break
		fi
		current_try=$(($current_try+1))
		echowrapper "Same value as before for $current_try time ($nr)"
	else
		current_try=0
		old_nr=$nr
	fi

	sleep $INTERVAL
done

# Destroy the other screen as it is no longer needed
echowrapper `settings delete global overlay_display_devices`

# (Hopefully) Restore sane defaults
# settings put global enable_freeform_support 0
# settings put global force_resizable_activities 0

# Restore old keyboard
echowrapper `ime disable $NULL_KEYBOARD`
echowrapper `ime set $DEFAULT_KEYBOARD`

