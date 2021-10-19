
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

### On Linux

Just run ```startscreen.sh```, it should do all the magic itself.

NOTE: It may or may not prompt you to restart your device, which you have to do
for a one-time setup. After that, you no longer need to do (unless you change
that particular option under developer settings)

#### Changing options

When running the ```startscreen.sh``` script you can change the resolution and
DPI via command-line arguments, for example: ```./startscreen.sh 1920x1080 120```

### On Windows

1. [Download this repo](https://github.com/nikp123/scrcpy-desktop/archive/refs/heads/main.zip)
and extract the contents.
2. Inside this repo, create a folder named ```bin```.
3. [Download scrcpy](https://github.com/Genymobile/scrcpy/releases) and extract
it's contents so that the ```.exe``` files are located within the bin folder and
not as an sub-folder.
4. Open the extracted repo folder within explorer.
5. Type ```powershell``` within the address bar and press enter
6. Type ```.\startscreen.ps1 -Resolution widthxheight -DPI your_desired_dpi``` and
press enter.
7. If Windows bothers you with a prompt talking about trust, press R to run the
script.
8. Enjoy.


Limitations
-----------

 * No audio at all
 * A very botched implementation ATM
 * The Windows version has no way to automatically obtain the resolution


Credits:
--------

https://github.com/Genymobile/scrcpy - The magic that made this possible

https://github.com/reversegear/scrcpy-pi-omx - Where this idea came from and
what the code was inspired by

