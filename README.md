
 [![image alt text](https://github.com/nikp123/scrcpy-desktop/blob/98c8dfce3d5d1f52962aecc32c819d847a2ba500/image.png)](https://github.com/nikp123/scrcpy-desktop/blob/98c8dfce3d5d1f52962aecc32c819d847a2ba500/image.png)

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

NOTE: The current version will reboot your phone. THIS IS INTENTIONAL, it's done so that the operating system doesn't bug out as it usually does with this mode enabled.


Limitations
-----------

 * Only 1080p mode supported
 * OSK may be bugging you (a workaround is to disable it or have a bluetooth keyboard instead)
 * No audio at all
 * A very botched implementation ATM


Credits:
--------

https://github.com/Genymobile/scrcpy - The magic that made this possible

https://github.com/reversegear/scrcpy-pi-omx - Where this idea came from and
what the code was inspired by

