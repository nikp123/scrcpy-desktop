# This script changes the file's contents for every x seconds, so the connected device can check if the external display is still connected.
# It is used instead of relying on monitoring scrcpy server process, which doesn't terminate when scrcpy is used through Wi-Fi and Wi-Fi connection is lost.
# Keep in mind that it isn't possible to revert all changes when adb is restarted on an android device. It kills adb shell and all of its children,
# without leaving them a way to handle it. Those times you will need to reset device manually to expected state, so change IME and remove virtual display.

param($FILE, $INTERVAL, $ADB)

$number = 0
while ($true) {
    & $ADB shell "echo $number > $FILE"
    # & $ADB shell "cat $FILE"
    $number = ($number + 1) % 2
    Start-Sleep $INTERVAL
}
