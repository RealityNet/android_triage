# Android Triage

Bash script to extract data from an Android device

Developed and tested on Mac OS X Mojave (10.14.6), but works also on Linux

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

<b>Option 3 - Execute package manager commands</b>

- adb shell pm get-max-users
- adb shell pm list users
- adb shell pm list features
- adb shell pm list instrumentation
- adb shell pm list libraries -f
- adb shell pm list packages -f
- adb shell pm list packages -f -u
- adb shell pm list permissions -f
- adb shell cat /data/system/uiderrors.txt

<b>Option 4 - Execute bugreport,dumpsys,appops</b>

- adb shell bugreport
- adb shell dumpsys
- adb shell dumpsys account
- adb shell dumpsys activity
- adb shell dumpsys alarm
- adb shell dumpsys appops
- adb shell dumpsys audio
- adb shell dumpsys autofill
- adb shell dumpsys backup
- adb shell dumpsys battery
- adb shell dumpsys batteryproperties
- adb shell dumpsys batterystats
- adb shell dumpsys bluetooth_manager
- adb shell dumpsys bluetooth_manager | grep 'BOOT_COMPLETED\|AIRPLANE'
- adb shell dumpsys carrier_config
- adb shell dumpsys clipboard
- adb shell dumpsys connectivity
- adb shell dumpsys content
- adb shell dumpsys cpuinfo
- adb shell dumpsys dbinfo
- adb shell dumpsys dbinfo -v
- adb shell dumpsys device_policy
- adb shell dumpsys devicestoragemonitor
- adb shell dumpsys diskstats   
- adb shell dumpsys display
- adb shell dumpsys dropbox
- adb shell dumpsys gfxinfo
- adb shell dumpsys iphonesubinfo
- adb shell dumpsys jobscheduler
- adb shell dumpsys location
- adb shell dumpsys meminfo -t 60 -a
- adb shell dumpsys mount
- adb shell dumpsys netpolicy
- adb shell dumpsys netstats
- adb shell dumpsys network_management
- adb shell dumpsys network_score
- adb shell dumpsys notification
- adb shell dumpsys notification --noredact
- adb shell dumpsys package
- adb shell dumpsys password_policy
- adb shell dumpsys permission
- adb shell dumpsys phone
- adb shell dumpsys power
- adb shell dumpsys procstats --full-details
- adb shell dumpsys restriction_policy
- adb shell dumpsys sdhms
- adb shell dumpsys sec_location
- adb shell dumpsys secims
- adb shell dumpsys search
- adb shell dumpsys sensorservice
- adb shell dumpsys settings
- adb shell dumpsys shortcut
- adb shell dumpsys stats
- adb shell dumpsys statusbar
- adb shell dumpsys storaged
- adb shell dumpsys telecom
- adb shell dumpsys usagestats
- adb shell dumpsys user
- adb shell dumpsys usb
- adb shell dumpsys vibrator
- adb shell dumpsys voip
- adb shell dumpsys wallpaper
- adb shell dumpsys wifi
- adb shell dumpsys window
- adb shell appops get $pkg

<b>Option 5 - Acquire an ADB Backup</b>

- adb backup -all -shared -system -keyvalue -apk -obb -f backup.ab

<b>Option 6 - Acquire /system folder</b>

- adb pull /system/
- adb pull /system/apex
- adb pull /system/app
- adb pull /system/bin
- adb pull /system/cameradata
- adb pull /system/container
- adb pull /system/etc
- adb pull /system/fake-libs
- adb pull /system/fonts
- adb pull /system/framework
- adb pull /system/hidden
- adb pull /system/lib
- adb pull /system/lib64
- adb pull /system/media
- adb pull /system/priv-app
- adb pull /system/saiv
- adb pull /system/tts
- adb pull /system/usr
- adb pull /system/vendor
- adb pull /system/xbin

<b>Option 7 - Acquire /sdcard folder</b>

- adb pull /sdcard

<b>Option 8 - Acquire /data/app folder</b>

- adb pull /data/app/${app_path}/

<b>Option 9 - Extract data from content providers</b>

- adb shell dumpsys package providers
- adb shell content query --uri content://com.android.calendar/calendar_entities
- adb shell content query --uri content://com.android.calendar/calendars
- adb shell content query --uri content://com.android.calendar/attendees
- adb shell content query --uri content://com.android.calendar/event_entities
- adb shell content query --uri content://com.android.calendar/events
- adb shell content query --uri content://com.android.calendar/properties
- adb shell content query --uri content://com.android.calendar/reminders
- adb shell content query --uri content://com.android.calendar/calendar_alerts
- adb shell content query --uri content://com.android.calendar/colors
- adb shell content query --uri content://com.android.calendar/extendedproperties
- adb shell content query --uri content://com.android.calendar/syncstate
- adb shell content query --uri content://com.android.contacts/raw_contacts
- adb shell content query --uri content://com.android.contacts/directories
- adb shell content query --uri content://com.android.contacts/syncstate
- adb shell content query --uri content://com.android.contacts/profile/syncstate
- adb shell content query --uri content://com.android.contacts/contacts
- adb shell content query --uri content://com.android.contacts/profile/raw_contacts
- adb shell content query --uri content://com.android.contacts/profile
- adb shell content query --uri content://com.android.contacts/profile/as_vcard
- adb shell content query --uri content://com.android.contacts/stream_items
- adb shell content query --uri content://com.android.contacts/stream_items/photo
- adb shell content query --uri content://com.android.contacts/stream_items_limit
- adb shell content query --uri content://com.android.contacts/data
- adb shell content query --uri content://com.android.contacts/raw_contact_entities
- adb shell content query --uri content://com.android.contacts/profile/raw_contact_entities
- adb shell content query --uri content://com.android.contacts/status_updates
- adb shell content query --uri content://com.android.contacts/data/phones
- adb shell content query --uri content://com.android.contacts/data/phones/filter
- adb shell content query --uri content://com.android.contacts/data/emails/lookup
- adb shell content query --uri content://com.android.contacts/data/emails/filter
- adb shell content query --uri content://com.android.contacts/data/emails
- adb shell content query --uri content://com.android.contacts/data/postals
- adb shell content query --uri content://com.android.contacts/groups
- adb shell content query --uri content://com.android.contacts/groups_summary
- adb shell content query --uri content://com.android.contacts/aggregation_exceptions
- adb shell content query --uri content://com.android.contacts/settings
- adb shell content query --uri content://com.android.contacts/provider_status
- adb shell content query --uri content://com.android.contacts/photo_dimensions
- adb shell content query --uri content://com.android.contacts/deleted_contacts
- adb shell content query --uri content://downloads/my_downloads
- adb shell content query --uri content://downloads/download
- adb shell content query --uri content://media/external/file
- adb shell content query --uri content://media/external/images/media
- adb shell content query --uri content://media/external/images/thumbnails
- adb shell content query --uri content://media/external/audio/media
- adb shell content query --uri content://media/external/audio/genres
- adb shell content query --uri content://media/external/audio/playlists
- adb shell content query --uri content://media/external/audio/artists
- adb shell content query --uri content://media/external/audio/albums
- adb shell content query --uri content://media/external/video/media
- adb shell content query --uri content://media/external/video/thumbnails
- adb shell content query --uri content://media/internal/file
- adb shell content query --uri content://media/internal/images/media
- adb shell content query --uri content://media/internal/images/thumbnails
- adb shell content query --uri content://media/internal/audio/media
- adb shell content query --uri content://media/internal/audio/genres
- adb shell content query --uri content://media/internal/audio/playlists
- adb shell content query --uri content://media/internal/audio/artists
- adb shell content query --uri content://media/internal/audio/albums
- adb shell content query --uri content://media/internal/video/media
- adb shell content query --uri content://media/internal/video/thumbnails
- adb shell content query --uri content://settings/system
- adb shell content query --uri content://settings/system/ringtone
- adb shell content query --uri content://settings/system/alarm_alert
- adb shell content query --uri content://settings/system/notification_sound
- adb shell content query --uri content://settings/secure
- adb shell content query --uri content://settings/global
- adb shell content query --uri content://settings/bookmarks
- adb shell content query --uri content://com.google.settings/partner
- adb shell content query --uri content://nwkinfo/nwkinfo/carriers
- adb shell content query --uri content://com.android.settings.personalvibration.PersonalVibrationProvider/
- adb shell content query --uri content://settings/system/bluetooth_devices
- adb shell content query --uri content://settings/system/powersavings_appsettings
- adb shell content query --uri content://user_dictionary/words
- adb shell content query --uri content://browser/bookmarks
- adb shell content query --uri content://browser/searches
- adb shell content query --uri content://com.android.browser
- adb shell content query --uri content://com.android.browser/accounts
- adb shell content query --uri content://com.android.browser/accounts/account_name
- adb shell content query --uri content://com.android.browser/accounts/account_type
- adb shell content query --uri content://com.android.browser/accounts/sourceid
- adb shell content query --uri content://com.android.browser/settings
- adb shell content query --uri content://com.android.browser/syncstate
- adb shell content query --uri content://com.android.browser/images
- adb shell content query --uri content://com.android.browser/image_mappings
- adb shell content query --uri content://com.android.browser/bookmarks
- adb shell content query --uri content://com.android.browser/bookmarks/folder
- adb shell content query --uri content://com.android.browser/history
- adb shell content query --uri content://com.android.browser/bookmarks/search_suggest_query
- adb shell content query --uri content://com.android.browser/searches
- adb shell content query --uri content://com.android.browser/combined

<b>Option 10 - Extract system dump (no root)</b>

- Option 6 + Option 7 + Option 8

