
 [![image alt text](https://github.com/nikp123/scrcpy-desktop/blob/98c8dfce3d5d1f52962aecc32c819d847a2ba500/image.png)](https://github.com/nikp123/scrcpy-desktop/blob/98c8dfce3d5d1f52962aecc32c819d847a2ba500/image.png)

For this to work you'll need to do the following:
-------------------------------------------------

 1. Have a proper USB cable that works
 (or a good Wi-Fi for use with ADB wireless)
 3. Have a PC that is ABLE to process real-time video
 4. Make sure that the connection is good (USB or Wi-Fi)
 5. Android 10 (MINIMUM) running on the device
 6. Developer mode enabled
 7. Your PC MUST have ADB access to your phone
 8. ADB and SCRCPY installed on your PC
 9. Proper binutils (for now) on the Android device


How to do it
------------

### On Android device

Install
[Null keyboard](https://play.google.com/store/apps/details?id=com.wparam.nullkeyboard)
and enable as an input layout it within your language settings.
It seams to be unavailable in playstore for a while now. In the meantime you can install it from reputable sources like apkmirror.

Install
[Taskbar](https://play.google.com/store/apps/details?id=com.farmerbb.taskbar).

If you don't you'll automatically get redirected to the Play Store page of those two apps.

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

Troubleshooting
---------------

If after running the script all you get is a black screen, that means that the
Android OS that you're running is missing a "desktop launcher". This can be fixed
by installing it, for example 
[Taskbar](https://play.google.com/store/apps/details?id=com.farmerbb.taskbar).

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

