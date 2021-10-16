#!/bin/bash

# This script is written to work with version 1.19 ONLY
SCRCPY_SERVER_URL="https://github.com/Genymobile/scrcpy/releases/download/v1.19/scrcpy-server-v1.19"

SCRCPY_PORT=27183
TMP_DIR=/tmp/scrcpy-desktop
TMP_STREAM=$TMP_DIR/stream
SCRCPY_JAR=$TMP_DIR/scrcpy_server.jar

TARGET_TMP_DIR=/data/local/tmp
TARGET_JAR=$TARGET_TMP_DIR/scrcpy-server.jar
TARGET_SCRIPT1=$TARGET_TMP_DIR/scrcpy-payload1.sh
TARGET_SCRIPT2=$TARGET_TMP_DIR/scrcpy-payload2.sh

# Create the temp dir
mkdir -p $TMP_DIR

# Download the payload binary
wget "$SCRCPY_SERVER_URL" -O $SCRCPY_JAR

# Pushing the payload JAR scrcpy server
adb push $SCRCPY_JAR $TARGET_JAR

# Establishing a port connection
adb reverse localabstract:scrcpy tcp:$SCRCPY_PORT

# Add a FIFO stream to said port
mkfifo $TMP_STREAM
nc -l -p $SCRCPY_PORT > $TMP_STREAM &

# Launch the player (in the background)
mpv $TMP_STREAM --profile=low-latency --untimed &

# A slight delay so that the server recognizes the listener immediatelly
sleep .5

#
# Payload section starts here
#

# Execute the payload stream generator remotely (with precisely the parameters that it wants)
adb push payload/stage1.sh $TARGET_SCRIPT1
adb push payload/stage2.sh $TARGET_SCRIPT2
adb shell chmod +x $TARGET_SCRIPT1
adb shell chmod +x $TARGET_SCRIPT2
adb shell $TARGET_SCRIPT1

# Potentially dangerous cleanup operations
rm $TMP_STREAM
rm -rf $TMP_DIR

exit 0
