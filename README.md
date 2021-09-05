# Android Triage

Bash script to extract data from an Android device

Developed and tested on Mac OS X Mojave (10.14.6), but should work also on Linux

<b>Mandatory Requirements</b>

- adb (https://developer.android.com/studio/releases/platform-tools)
- dialog (for Mac OS X see here http://macappstore.org/dialog/)

<b>How to use it</b>

- Activate ADB on the Android Device
- Connect and pair the Android Device and the host
- Make the script executable (chmod +x android_triage.sh)
- Execute the script and follow the instructions

See also the original blog post here

https://blog.digital-forensics.it/2021/03/triaging-modern-android-devices-aka.html

<b>Version 1.0 [30/3/2020]</b>

First release

<b>Version 1.1 [30/3/2020]</b>

- Added "-keyvalue" in the ADB backup commant (Thanks Yogesh Khatri - @SwiftForensics)
- Added option 10 to dump file system folders and files not requiring root privileges
- Minor fixes

<b>Version 1.2 [3/4/2020]</b>

- Added "dumpsys diskstats" processing (credits https://android.stackexchange.com/questions/220442/obtaining-app-storage-details-via-adb)
- Added "appops" processing (credits https://android.stackexchange.com/questions/226282/how-can-i-see-which-applications-is-reading-the-clipboard)
- Minor adds

<b>Version 1.3 [6/9/2020]</b>

- Added "dumpsys notification --noredact" to extract notification text 
- Added "dumpsys dbinfo -v"
- Added "dumpsys bluetooth_manager | grep 'BOOT_COMPLETED\|AIRPLANE'" to extract boot and airplane mode information
- Changed "dumpsys meminfo -a" with "dumpsys -t 60 meminfo -a"
- Minor fixes
