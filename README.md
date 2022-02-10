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

<b>Version 1.0 [30/3/2021]</b>

First release

<b>Version 1.1 [30/3/2021]</b>

- Added "-keyvalue" in the ADB backup commant (Thanks Yogesh Khatri - @SwiftForensics)
- Added option 10 to dump file system folders and files not requiring root privileges
- Minor fixes

<b>Version 1.2 [3/4/2021]</b>

- Added "dumpsys diskstats" processing (credits https://android.stackexchange.com/questions/220442/obtaining-app-storage-details-via-adb)
- Added "appops" processing (credits https://android.stackexchange.com/questions/226282/how-can-i-see-which-applications-is-reading-the-clipboard)
- Minor adds

<b>Version 1.3 [6/9/2021]</b>

- Added "dumpsys notification --noredact" to extract notification text 
- Added "dumpsys dbinfo -v"
- Added "dumpsys bluetooth_manager | grep 'BOOT_COMPLETED\|AIRPLANE'" to extract boot and airplane mode information
- Changed "dumpsys meminfo -a" with "dumpsys -t 60 meminfo -a"
- Minor fixes

<b>Version 1.4 [11/2/2022]</b>

- Added full "/data/app" acquisition (not only APKs, but also libs and other files)
- Add "-obb" option to the ADB Backup command
- Added "References" section
- Added "Special thanks" section
- Minor fixes

<b>List of executed commands</b>

<b>Option 1 - Collect basic information</b>

- adb shell getprop
- adb shell settings list system
- adb shell settings list secure
- adb shell settings list global
- adb shell getprop ro.product.model
- adb shell getprop ro.product.manufacturer
- adb shell settings get global airplane_mode_on
- adb shell getprop ro.serialno
- adb shell getprop ro.build.fingerprint
- adb shell getprop ro.build.version.release
- adb shell getprop ro.build.date
- adb shell getprop ro.build.id
- adb shell getprop ro.boot.bootloader
- adb shell getprop ro.build.version.security_patch
- adb shell settings get secure bluetooth_address
- adb shell settings get secure bluetooth_name
- adb shell getprop persist.sys.timezone
- adb shell getprop ro.product.manufacturer
- adb shell getprop ro.product.device
- adb shell getprop ro.product.name
- adb shell getprop ro.product.code
- adb shell getprop ro.chipname
- adb shell getprop ril.serialnumber
- adb shell getprop gsm.version.baseband
- adb shell getprop ro.csc.country_code
- adb shell getprop persist.sys.usb.config
- adb shell getprop storage.mmc.size
- adb shell getprop ro.config.notification_sound
- adb shell getprop ro.config.alarm_alert
- adb shell getprop ro.config.ringtone
- adb shell getprop rro.config.media_sound
- adb shell date
- adb shell getprop ro.crypto.state
- adb shell uptime -s
- adb shell getprop ro.crypto.type
- adb shell dumpsys iphonesubinfo
- adb shell service call iphonesubinfo
- adb shell id
- adb shell su -c id

<b>Option 2 - Execute live commands</b>

- adb shell id
- adb shell uname -a
- adb shell cat /proc/version
- adb shell uptime
- adb shell printenv
- adb shell cat /proc/partitions
- adb shell cat /proc/cpuinfo
- adb shell cat /proc/diskstats
- adb shell df
- adb shell df -ah
- adb shell mount
- adb shell ip address show wlan0
- adb shell ifconfig -a
- adb shell netstat -an
- adb shell lsof
- adb shell ps -ef
- adb shell top -n 1
- adb shell cat /proc/sched_debug
- adb shell vmstat
- adb shell sysctl -a
- adb shell ime list
- adb shell service list
- adb shell logcat -S -b all
- adb shell logcat -d -b all V:*



