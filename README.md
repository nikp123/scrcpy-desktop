
For this to work you'll need to do the following:
-------------------------------------------------

 1. Have a proper USB cable that works
 2. Have a PC that is ABLE to process real-time video
 3. A proper USB connection between the Android device and the PC in question
 4. Android 10 (MINIMUM) running on the device
 5. Developer mode enabled
 6. Your PC MUST have ADB access to your phone
 7. ADB and SCRCPY installed on your PC
 8. Proper binutils (for now) on the Android device


How to do it
------------

Just run ```startscreen.sh```, it should do all the magic itself.


Limitations
-----------

 * Only 1080p mode supported
 * No input whatsoever
 * OSK may be bugging you
 * Non-portable (as it's scrcpy version dependent)
 * No audio at all
 * A very botched implementation ATM


Credits:
--------

https://github.com/Genymobile/scrcpy - The magic that made this possible

https://github.com/reversegear/scrcpy-pi-omx - Where this idea came from and
what the code was inspired by

