#!/system/bin/sh

# Where's my fucking UNIX degree already
while ps -Afo PID,ARGS=CMD | grep CLASSPATH | grep -v grep; do
	sleep 1
done

# Destroy the other screen as it is no longer needed
settings put global overlay_display_devices 0

# (Hopefully) Restore sane defaults
settings put global enable_freeform_support 0
settings put global force_resizable_activities 0

