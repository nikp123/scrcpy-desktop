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
# fault and leave the host system in an unsafe state as a result
#

TARGET_TMP_DIR=/data/local/tmp
TARGET_SCRIPT2=$TARGET_TMP_DIR/scrcpy-payload2.sh

sh $TARGET_SCRIPT2 &
WAIT_PID=$!

wait $WAIT_PID

