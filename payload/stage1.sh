#!/system/bin/sh

#
# The first payload is just the "real payload wrapper"
#
# This basically runs the other payload and waits for it to finish
# This serves two really important functions.
# All the commands for cleanup are available on the system instead of being
# streamed in as they're run. Which becomes impossible once the connection is
# dead. - The reason why stage 1 was written.
#
# Stage 2 basically makes sure that the script doesn't get aborted because of an
# fault and leave the host system in an unsafe state as a result (except when adbd on device is restarted,
# then nothing can be reverted by code since the shell the sripts runs under is being killed, which also kills the cleanup script)\

TARGET_TMP_DIR=/data/local/tmp
TARGET_SCRIPT2=$TARGET_TMP_DIR/scrcpy-payload2.sh
FILE=$1
INTERVAL=$2

sh $TARGET_SCRIPT2 $FILE $INTERVAL &
WAIT_PID=$!

wait $WAIT_PID

