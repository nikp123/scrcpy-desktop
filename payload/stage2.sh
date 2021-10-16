#!/system/bin/sh

TARGET_TMP_DIR=/data/local/tmp
TARGET_JAR=$TARGET_TMP_DIR/scrcpy-server.jar

# Screen res/DPI (doesn't accept all values unfortunately)
TARGET_DISPLAY_MODE=1920x1080/142

# Change secondary display behaviour
settings put global enable_freeform_support 1
settings put global force_desktop_mode_on_external_displays 1
settings put global force_resizable_activities 1

# Use the secondary screen option to generate the other screen
settings put global overlay_display_devices $TARGET_DISPLAY_MODE

# Wait for the display to appear
sleep 1

# Get the non-phone screen
display=$(dumpsys display | grep "  Display " | cut -d' ' -f4 | grep -v "0:" | sed -e 's/://')

# Launch the server
CLASSPATH=$TARGET_JAR app_process / com.genymobile.scrcpy.Server 1.19 info 0 200000000 0 -1 false - true true $display false false - - false

# Destroy the other screen as it is no longer needed
settings put global overlay_display_devices 0

# (Hopefully) Restore sane defaults
settings put global enable_freeform_support 0
settings put global force_desktop_mode_on_external_displays 0
settings put global force_resizable_activities 0

