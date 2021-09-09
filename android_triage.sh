#!/bin/bash

# android_triage
# Mattia Epifani && Giovanni Rattaro
# 20210906 V1.3
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#####################################################################
# MANDATORY REQUIREMENTS
#####################################################################
#
# - adb
# - dialog
#
#####################################################################

time_update () { NOW=$(date +"%Y%m%d_%H_%M_%S"); }

check_tools() {
        TOOL="adb"
        if [ "$(command -v "$TOOL" | wc -l)" == "1" ]; then
           ADB="$(command -v "$TOOL")"
           else
             if [[ -f "./$TOOL" ]]; then
                 ADB="./$TOOL"
               else
                 clear && dialog --title "Android triage" --msgbox "$TOOL NOT FOUND! It's not possible to use android_triage script" 6 45
	    	 exit
             fi
        fi
}

set_var () {
	# generic var
	VERSION="1.3 - 20210906"

	# generic commands var
	SHELL_COMMAND="${ADB} shell"
	BACKUP_COMMAND="${ADB} backup"
	PULL_COMMAND="${ADB} pull"
	BUGREPORT_COMMAND="${ADB} bugreport"

	# Android ID
	ANDROID_ID=$($SHELL_COMMAND settings get secure android_id)
    
}

set_path () {
	clear && time_update
	    
	# Generic path var
	SPATH="${ANDROID_ID}"

	# Directories for device information
	INFO_DIR="${SPATH}/${NOW}_info"
	INFO_TXT_FILE="${INFO_DIR}/device_info.txt"
    
	# Directories for live commands execution
	LIVE_DIR="${SPATH}"/${NOW}_live
	LIVE_LOG_FILE="$LIVE_DIR/log_live_acquisition.txt"

	# Directories for package manager execution
	PM_DIR="${SPATH}"/${NOW}_package_manager
	PM_LOG_FILE="$PM_DIR/log_pm_acquisition.txt"

	# Directories for DUMPSYS acquisition
	DUMPSYS_DIR="${SPATH}/${NOW}_dumpsys"
	DUMPSYS_LOG_FILE="$DUMPSYS_DIR/log_dumpsys_acquisition.txt"

	# Directories for SDCARD acquisition
	SDCARD_DIR="${SPATH}/${NOW}_sdcard"
	SDCARD_LOG_FILE="$SDCARD_DIR/log_sdcard_acquisition.txt"

	# Directories for SYSTEM acquisition
	SYSTEM_DIR="${SPATH}/${NOW}_system"
	SYSTEM_LOG_FILE="$SYSTEM_DIR/log_system_acquisition.txt"

	# Directories for 'private' image
	BACKUP_DIR="${SPATH}/${NOW}_backup"

	# Directories for APKs image
	APK_DIR="${SPATH}/${NOW}_apk"
	APK_LOG_FILE="$APK_DIR/log_apk_acquisition.txt"

	# Directories for content providers
	CONTENTPROVIDER_DIR="${SPATH}/${NOW}_contentprovider"
	CONTENTPROVIDER_LOG_FILE="$CONTENTPROVIDER_DIR/${NOW}_contentprovider.txt"
    
	# Directories for file system dump
	ALL_DIR="${SPATH}/${NOW}_filesystem"
	ALL_LOG_FILE="$ALL_DIR/log_filesystem_acquisition.txt"
}

check_device () {
	if [ -z "$ANDROID_ID" ];then
	   clear && dialog --title "android triage" --msgbox "NO DEVICE CONNECTED!" 5 24 && clear && exit
	fi
}

info_collect () {
        set_path
        mkdir -p "$INFO_DIR"
        $SHELL_COMMAND getprop > "${INFO_DIR}"/getprop.txt
        $SHELL_COMMAND settings list system > "${INFO_DIR}"/settings_system.txt
        $SHELL_COMMAND settings list secure > "${INFO_DIR}"/settings_secure.txt
        $SHELL_COMMAND settings list global > "${INFO_DIR}"/settings_global.txt
        PRODUCT=$($SHELL_COMMAND getprop ro.product.model)
        MANUFACTURER=$($SHELL_COMMAND getprop ro.product.manufacturer)
        echo "[*] Dumping info from ${MANUFACTURER} ${PRODUCT}"       
        AIRPLANE_MODE=$($SHELL_COMMAND settings get global airplane_mode_on)
        ANDROID_SERIAL_NUMBER=$($SHELL_COMMAND getprop ro.serialno)
        FINGERPRINT=$($SHELL_COMMAND getprop ro.build.fingerprint)
        ANDROID_VERSION=$($SHELL_COMMAND getprop ro.build.version.release)
        BUILD_DATE=$($SHELL_COMMAND getprop ro.build.date)
        BUILD_ID=$($SHELL_COMMAND getprop ro.build.id)
        BOOTLOADER=$($SHELL_COMMAND getprop ro.boot.bootloader)
        SECURITY_PATCH=$($SHELL_COMMAND getprop ro.build.version.security_patch)
        BLUETOOTH_MAC=$($SHELL_COMMAND settings get secure bluetooth_address)
        BLUETOOTH_NAME=$($SHELL_COMMAND settings get secure bluetooth_name)
        TIMEZONE=$($SHELL_COMMAND getprop persist.sys.timezone)
        MANUFACTURER=$($SHELL_COMMAND getprop ro.product.manufacturer)
        DEVICE=$($SHELL_COMMAND getprop ro.product.device)
        NAME=$($SHELL_COMMAND getprop ro.product.name)
        PRODUCT_CODE=$($SHELL_COMMAND getprop ro.product.code)
        CHIPNAME=$($SHELL_COMMAND getprop ro.chipname)
        SERIAL_NUMBER=$($SHELL_COMMAND getprop ril.serialnumber)
        BASEBAND_VERSION=$($SHELL_COMMAND getprop gsm.version.baseband)
        COUNTRY_CODE=$($SHELL_COMMAND getprop ro.csc.country_code)
        USB_CONFIGURATION=$($SHELL_COMMAND getprop persist.sys.usb.config)
        STORAGE_SIZE=$($SHELL_COMMAND getprop storage.mmc.size)
        NOTIFICATION_SOUND=$($SHELL_COMMAND getprop ro.config.notification_sound)
        ALARM_ALERT=$($SHELL_COMMAND getprop ro.config.alarm_alert)
        RINGTONE=$($SHELL_COMMAND getprop ro.config.ringtone)
        MEDIA_SOUND=$($SHELL_COMMAND getprop rro.config.media_sound)
        DEVICE_TIME=$($SHELL_COMMAND date)
        ENCRYPTION=$($SHELL_COMMAND getprop ro.crypto.state)
        UPTIME=$($SHELL_COMMAND uptime -s)

        ENCRYPTION_TYPE="none"
        if [[ ! ${ENCRYPTION} =~ "unecrypted" ]]; then
	       ENCRYPTION_TYPE=$(${ADB} shell getprop ro.crypto.type)
        fi

        IMEI=$(${ADB} shell dumpsys iphonesubinfo | grep 'Device ID' | grep -o '[0-9]+')
        if [[ -z ${IMEI} ]]; then
	       IMEI=$(${ADB} shell service call iphonesubinfo 1 | awk -F "'" '{print $2}' | sed '1 d' | tr -d '.' | awk '{print}' ORS=)
        fi

        if [[ $(adb shell id) =~ "root" ]] || [[ $(adb shell su -c id) =~ "root" ]];then 
	       ROOT="Device is ROOTED!"
        else
	       ROOT="Device is NOT ROOTED"
        fi
        
        dialog --title "android triage" --msgbox "\n
        [*] Dumping info from ${MANUFACTURER} ${PRODUCT} \n
        [*] Android_id: ${ANDROID_ID} \n
        [*] Android Serial number: ${ANDROID_SERIAL_NUMBER} \n
        [*] Serial number: ${SERIAL_NUMBER} \n 
        [*] IMEI: ${IMEI} \n
        [*] Android version: ${ANDROID_VERSION} \n
        [*] Chipname: ${CHIPNAME} \n
        [*] Build date: ${BUILD_DATE} \n
        [*] Security Patch: ${SECURITY_PATCH} \n
        [*] Timezone: ${TIMEZONE} \n 
        [*] ${ROOT} \n
        [*] Device is ${ENCRYPTION} \n
        [*] Encryption type: ${ENCRYPTION_TYPE}" 20 70
        
	echo "[*]
	[*] Dumping info from device ${MANUFACTURER} ${PRODUCT} 
	[*] Android_id: ${ANDROID_ID}
	[*] Android Serial number: ${ANDROID_SERIAL_NUMBER}
	[*] Serial number: ${SERIAL_NUMBER}
	[*] IMEI: ${IMEI}
	[*] Android version: ${ANDROID_VERSION}
	[*] Product Code: ${PRODUCT_CODE}
	[*] Product Device: ${DEVICE}
	[*] Product Name: ${NAME}
	[*] Chipname: ${CHIPNAME}
	[*] Android fingerprint: ${FINGERPRINT}
	[*] Build date: ${BUILD_DATE}
	[*] Build ID: ${BUILD_ID}
	[*] Bootloader: ${BOOTLOADER}
	[*] Security Patch: ${SECURITY_PATCH}
	[*] Bluetooth_address: ${BLUETOOTH_MAC}
	[*] Bluetooth_name: ${BLUETOOTH_NAME}
	[*] Timezone: ${TIMEZONE}
	[*] USB Configuration: ${USB_CONFIGURATION}
	[*] Storage Size: ${STORAGE_SIZE}
	[*] Notification sound: ${NOTIFICATION_SOUND}
	[*] Alarm alert: ${ALARM_ALERT}
	[*] Ringtone: ${RINGTONE}
	[*] Media sound: ${MEDIA_SOUND}
	[*] Uptime since: ${UPTIME}
	[*] Device time: ${DEVICE_TIME}
	[*] Acquisition time: ${NOW}
	[*] ${ROOT}
	[*] Device is ${ENCRYPTION}" > "$INFO_TXT_FILE"

	if [[ ! ${ENCRYPTION_TYPE} =~ "none" ]]; then
	    echo "[*] Encryption type: ${ENCRYPTION_TYPE}" >> "$INFO_TXT_FILE"
	fi
	if [[ ${AIRPLANE_MODE} = "1" ]]; then
	    echo "[*] Airplane mode is ON" >> "$INFO_TXT_FILE" 
	  else
	    echo "[*] Airplane mode is OFF" >> "$INFO_TXT_FILE"
	fi

        clear && dialog --title "android triage" --msgbox "DEVICE INFO acquisition completed" 5 40
        menu
}

live_commands () {
	set_path
	mkdir -p "$LIVE_DIR"
	echo -e "[*]\n[*]"
	echo "[*] This option executes 20 live commands on the device. The executions should take about 20 seconds"
	echo -e "[*]\n[*]"
	echo "[*] LIVE Acquisition started at ${NOW}" | tee $LIVE_LOG_FILE
	echo -e "[*]\n[*]"     
	echo "[*] Executing live commands"
	echo "[*] id" && $SHELL_COMMAND id > "$LIVE_DIR"/id.txt
	echo "[*] uname -a" && $SHELL_COMMAND uname -a > "$LIVE_DIR"/uname-a.txt
	echo "[*] cat /proc/version" && $SHELL_COMMAND cat /proc/version > "$LIVE_DIR"/kernel_version.txt
	echo "[*] uptime" && $SHELL_COMMAND uptime > "$LIVE_DIR"/uptime.txt    
	echo "[*] printenv" && $SHELL_COMMAND printenv > "$LIVE_DIR"/printenv.txt 
	echo "[*] cat /proc/partitions" && $SHELL_COMMAND cat /proc/partitions > "$LIVE_DIR"/partitions.txt
	echo "[*] cat /proc/cpuinfo" && $SHELL_COMMAND cat /proc/cpuinfo > "$LIVE_DIR"/cpuinfo.txt 
	echo "[*] cat /proc/diskstats" && $SHELL_COMMAND cat /proc/diskstats > "$LIVE_DIR"/diskstats.txt  
	echo "[*] df" && $SHELL_COMMAND df > "$LIVE_DIR"/df.txt
	echo "[*] df -ah" && $SHELL_COMMAND df -ah > "$LIVE_DIR"/df-ah.txt 
	echo "[*] mount" && $SHELL_COMMAND mount > "$LIVE_DIR"/mount.txt 
	echo "[*] ip address show wlan0" && $SHELL_COMMAND ip address show wlan0 > "$LIVE_DIR"/ip_wlan0.txt 
	echo "[*] ifconfig -a" && $SHELL_COMMAND ifconfig -a > "$LIVE_DIR"/ifconfig-a.txt 
	echo "[*] netstat -an" && $SHELL_COMMAND netstat -an > "$LIVE_DIR"/netstat-an.txt 
	echo "[*] lsof" && $SHELL_COMMAND lsof > "$LIVE_DIR"/lsof.txt 
	echo "[*] ps -ef" && $SHELL_COMMAND ps -ef > "$LIVE_DIR"/ps-ef.txt 
	echo "[*] top -n 1" && $SHELL_COMMAND top -n 1 > "$LIVE_DIR"/top.txt     
	echo "[*] cat /proc/sched_debug" && $SHELL_COMMAND cat /proc/sched_debug > "$LIVE_DIR"/proc_sched_debug.txt   
	echo "[*] vmstat" && $SHELL_COMMAND vmstat > "$LIVE_DIR"/vmstat.txt   
	echo "[*] sysctl -a" && $SHELL_COMMAND sysctl -a > "$LIVE_DIR"/sysctl-a.txt   
	echo "[*] ime list" && $SHELL_COMMAND ime list > "$LIVE_DIR"/ime_list.txt   
	echo "[*] service list" && $SHELL_COMMAND service list > "$LIVE_DIR"/service_list.txt
	echo "[*] logcat -S -b all" && $SHELL_COMMAND logcat -S -b all > "$LIVE_DIR"/logcat-S-b_all.txt
	echo "[*] logcat -d -b all V:*" && $SHELL_COMMAND logcat -d -b all V:*  > "$LIVE_DIR"/logcat-d-b-all_V.txt
	echo -e "[*]\n[*]"   
    
	time_update
	echo "[*] LIVE Acquisition completed at ${NOW}" | tee -a $LIVE_LOG_FILE
    
	clear && dialog --title "android triage" --msgbox "LIVE Acquisition completed at ${NOW}" 6 34
	menu
}

package_manager_commands () {
	set_path
	mkdir -p "$PM_DIR"

	echo -e "[*]\n[*]"
	echo "[*] This option executes 7 'pm' commands. The execution should take about 30 seconds"
	echo -e "[*]\n[*]"
	time_update
	echo "[*] PACKAGE MANAGER Acquisition started at ${NOW}" | tee $PM_LOG_FILE
	echo -e "[*]\n[*]"     
	echo "[*] Executing pm commands"
	echo "[*] pm get-max-users" && $SHELL_COMMAND pm get-max-users > "$PM_DIR"/pm_get_max_users.txt
	echo "[*] pm list users" && $SHELL_COMMAND pm list users > "$PM_DIR"/pm_list_users.txt
	echo "[*] pm list features" && $SHELL_COMMAND pm list features > "$PM_DIR"/pm_list_features.txt
	echo "[*] pm list instrumentation" && $SHELL_COMMAND pm list instrumentation > "$PM_DIR"/pm_list_instrumentation.txt
	echo "[*] pm list libraries -f" && $SHELL_COMMAND pm list libraries -f > "$PM_DIR"/pm_list_libraries-f.txt
	echo "[*] pm list packages -f" && $SHELL_COMMAND pm list packages -f > "$PM_DIR"/pm_list_packages-f.txt
	echo "[*] pm list packages -f -u" && $SHELL_COMMAND pm list packages -f -u > "$PM_DIR"/pm_list_packages-f-u.txt
	echo "[*] pm list permissions -f" && $SHELL_COMMAND pm list permissions -f > "$PM_DIR"/pm_list_permissions-f.txt
	echo "[*] cat /data/system/uiderrors.txt" && $SHELL_COMMAND cat /data/system/uiderrors.txt > "$PM_DIR"/uiderrors.txt
    
    #mkdir -p "$PM_DIR/package_dump"
    #for pkg in $( $SHELL_COMMAND pm list packages | sed 's/package://' )
    #do
    #    echo "[*] pm dump $pkg" && $SHELL_COMMAND pm dump $pkg > "$PM_DIR"/package_dump/"$pkg"_dump.txt
    #done
	#echo -e "[*]\n[*]"
    
	time_update
	echo "[*] PACKAGE MANAGER Acquisition completed at ${NOW}" | tee -a $PM_LOG_FILE
    
	clear && dialog --title "android triage" --msgbox "PACKAGE MANAGER Acquisition completed at ${NOW}" 6 40
	menu
}

sdcard () {
	set_path
	mkdir -p "$SDCARD_DIR"
	echo -e "[*]\n[*]"
	echo "[*] This option extracts files from /sdcard" 
	echo -e "[*]\n[*]"
	echo "[*] SDCARD acquisition started at ${NOW}" | tee "$SDCARD_LOG_FILE"
	echo -e "[*]\n[*]"		
	echo -e "[*]\n[*]"        
	mkdir -p ${SDCARD_DIR}/sdcard
	$PULL_COMMAND /sdcard/ ${SDCARD_DIR}/ >> "$SDCARD_LOG_FILE"
	echo "[*] Creating TAR file" 
	tar -cvf "$SDCARD_DIR"/sdcard.tar -C ${SDCARD_DIR} sdcard >> "$SDCARD_LOG_FILE" 2>/dev/null
	time_update
	echo -e "[*]\n[*]"    
	echo "[*] SDCARD acquisition completed at ${NOW}" | tee -a "$SDCARD_LOG_FILE"
	echo -e "[*]\n[*]"
	echo "[*] Calculating SHA hash" 
	shasum "$SDCARD_DIR"/sdcard.tar >> "$SDCARD_LOG_FILE" 2>&1

	clear && dialog --title "android triage" --msgbox "SDCARD acquisition completed at ${NOW}" 6 40
	menu    
}

dumpsys () {
	set_path
	mkdir -p "$DUMPSYS_DIR"
	echo -e "[*]\n[*]"
	echo "[*] This option extracts bugreport, dumpsys and appops information" 
	echo -e "[*]\n[*]"
	echo "[*] DUMPSYS acquisition started at ${NOW}" | tee "$DUMPSYS_LOG_FILE"
	echo -e "[*]\n[*]"		
	echo -e "[*]\n[*]"  
	echo "[*] Executing bugreport and dumpsys commands"
    echo "[*] bugreport" && $BUGREPORT_COMMAND "$DUMPSYS_DIR"/bugreport.zip
	echo "[*] dumpsys" && $SHELL_COMMAND dumpsys > "$DUMPSYS_DIR"/dumpsys.txt
	echo "[*] dumpsys account" && $SHELL_COMMAND dumpsys account > "$DUMPSYS_DIR"/dumpsys_account.txt 
    echo "[*] dumpsys activity" && $SHELL_COMMAND dumpsys activity > "$DUMPSYS_DIR"/dumpsys_activity.txt
    echo "[*] dumpsys alarm" && $SHELL_COMMAND dumpsys alarm > "$DUMPSYS_DIR"/dumpsys_alarm.txt  
	echo "[*] dumpsys appops" && $SHELL_COMMAND dumpsys appops > "$DUMPSYS_DIR"/dumpsys_appops.txt  
	echo "[*] dumpsys audio" && $SHELL_COMMAND dumpsys audio > "$DUMPSYS_DIR"/dumpsys_audio.txt  
 	echo "[*] dumpsys autofill" && $SHELL_COMMAND dumpsys autofill > "$DUMPSYS_DIR"/dumpsys_autofill.txt  
 	echo "[*] dumpsys backup" && $SHELL_COMMAND dumpsys backup > "$DUMPSYS_DIR"/dumpsys_backup.txt  
	echo "[*] dumpsys battery" && $SHELL_COMMAND dumpsys battery > "$DUMPSYS_DIR"/dumpsys_battery.txt 
	echo "[*] dumpsys batteryproperties" && $SHELL_COMMAND dumpsys batteryproperties > "$DUMPSYS_DIR"/dumpsys_batteryproperties.txt 
	echo "[*] dumpsys batterystats" && $SHELL_COMMAND dumpsys batterystats > "$DUMPSYS_DIR"/dumpsys_batterystats.txt
	echo "[*] dumpsys bluetooth_manager" && $SHELL_COMMAND dumpsys bluetooth_manager > "$DUMPSYS_DIR"/dumpsys_bluetooth_manager.txt
	echo "[*] dumpsys bluetooth_manager | grep 'BOOT_COMPLETED\|AIRPLANE'" && $SHELL_COMMAND dumpsys bluetooth_manager | grep 'BOOT_COMPLETED\|AIRPLANE' > "$DUMPSYS_DIR"/dumpsys_bluetooth_manager_boot.txt
    echo "[*] dumpsys carrier_config" && $SHELL_COMMAND dumpsys carrier_config > "$DUMPSYS_DIR"/dumpsys_carrier_config.txt
 	echo "[*] dumpsys clipboard" && $SHELL_COMMAND dumpsys clipboard > "$DUMPSYS_DIR"/dumpsys_clipboard.txt 
	echo "[*] dumpsys connectivity" && $SHELL_COMMAND dumpsys connectivity > "$DUMPSYS_DIR"/dumpsys_connectivity.txt
	echo "[*] dumpsys content" && $SHELL_COMMAND dumpsys content > "$DUMPSYS_DIR"/dumpsys_content.txt
	echo "[*] dumpsys cpuinfo" && $SHELL_COMMAND dumpsys cpuinfo > "$DUMPSYS_DIR"/dumpsys_cpuinfo.txt
	echo "[*] dumpsys dbinfo" && $SHELL_COMMAND dumpsys dbinfo > "$DUMPSYS_DIR"/dumpsys_dbinfo.txt 
    echo "[*] dumpsys dbinfo -v" && $SHELL_COMMAND dumpsys dbinfo -v > "$DUMPSYS_DIR"/dumpsys_dbinfo.txt 
    echo "[*] dumpsys device_policy" && $SHELL_COMMAND dumpsys device_policy > "$DUMPSYS_DIR"/dumpsys_device_policy.txt
    echo "[*] dumpsys devicestoragemonitor" && $SHELL_COMMAND dumpsys devicestoragemonitor > "$DUMPSYS_DIR"/dumpsys_devicestoragemonitor.txt
	echo "[*] dumpsys diskstats" && $SHELL_COMMAND dumpsys diskstats > "$DUMPSYS_DIR"/dumpsys_diskstats.txt 
    
    #Process dumpsys diskstats - See here https://android.stackexchange.com/questions/220442/obtaining-app-storage-details-via-adb
    
    F_PKG_NAMES="$DUMPSYS_DIR"/package_names.txt
    F_PKG_SIZE="$DUMPSYS_DIR"/app_pkg_sizes.txt
    F_DAT_SIZE="$DUMPSYS_DIR"/app_data_sizes.txt
    F_CACHE_SIZE="$DUMPSYS_DIR"/app_cache_sizes.txt
    F_OUTPUT="$DUMPSYS_DIR"/dumpsys_diskstats_ordered.txt
    sed -n '/Package Names:/p' "$DUMPSYS_DIR"/dumpsys_diskstats.txt | sed -e 's/,/\n/g' -e 's/"//g' -e 's/.*\[//g' -e 's/\].*//g' > "$F_PKG_NAMES"
    sed -n '/App Sizes:/p' "$DUMPSYS_DIR"/dumpsys_diskstats.txt | sed -e 's/,/\n/g' -e 's/.*\[//g' -e 's/\].*//g' > "$F_PKG_SIZE"
    sed -n '/App Data Sizes:/p' "$DUMPSYS_DIR"/dumpsys_diskstats.txt | sed -e 's/,/\n/g' -e 's/.*\[//g' -e 's/\].*//g' > "$F_DAT_SIZE"
    sed -n '/Cache Sizes:/p' "$DUMPSYS_DIR"/dumpsys_diskstats.txt | sed -e 's/,/\n/g' -e 's/.*\[//g' -e 's/\].*//g' > "$F_CACHE_SIZE"

    # Printing package names and their sizes 
    ttl_apps=$(wc -l < "$F_PKG_NAMES")
    count=1
    while [ $count -le $ttl_apps ]; do 
        pkg=$(sed -n "${count}p" "$F_PKG_NAMES")
        pkg_size=$(sed -n "${count}p" "$F_PKG_SIZE") 
        dat_size=$(sed -n "${count}p" "$F_DAT_SIZE")
        csh_size=$(sed -n "${count}p" "$F_CACHE_SIZE")
        echo -e "Package Name: $pkg" >> "$F_OUTPUT"
        echo -e "\t Package Size=$pkg_size bytes" >> "$F_OUTPUT"
        echo -e "\t Data Size=$dat_size bytes" >> "$F_OUTPUT"
        echo -e "\t Cache Size=$csh_size bytes" >> "$F_OUTPUT"
        echo -e "\t Total Size=$(($pkg_size + $dat_size + $csh_size)) bytes\n" >> "$F_OUTPUT"
    count=$(( $count + 1)); 
    done
    rm -f "$DUMPSYS_DIR"/package_names.txt
    rm -f "$DUMPSYS_DIR"/app_pkg_sizes.txt
    rm -f "$DUMPSYS_DIR"/app_data_sizes.txt
    rm -f "$DUMPSYS_DIR"/app_cache_sizes.txt
    
	echo "[*] dumpsys display" && $SHELL_COMMAND dumpsys display > "$DUMPSYS_DIR"/dumpsys_display.txt
	echo "[*] dumpsys dropbox" && $SHELL_COMMAND dumpsys dropbox > "$DUMPSYS_DIR"/dumpsys_dropbox.txt
	echo "[*] dumpsys gfxinfo" && $SHELL_COMMAND dumpsys gfxinfo > "$DUMPSYS_DIR"/dumpsys_gfxinfo.txt
    echo "[*] dumpsys iphonesubinfo" && $SHELL_COMMAND dumpsys iphonesubinfo > "$DUMPSYS_DIR"/dumpsys_iphonesubinfo.txt
    echo "[*] dumpsys jobscheduler" && $SHELL_COMMAND dumpsys jobscheduler > "$DUMPSYS_DIR"/dumpsys_jobscheduler.txt
	echo "[*] dumpsys location" && $SHELL_COMMAND dumpsys location > "$DUMPSYS_DIR"/dumpsys_location.txt 
	echo "[*] dumpsys -t 60 meminfo -a" && $SHELL_COMMAND dumpsys meminfo -t 60 -a > "$DUMPSYS_DIR"/dumpsys_meminfo-a.txt
	echo "[*] dumpsys mount" && $SHELL_COMMAND dumpsys mount > "$DUMPSYS_DIR"/dumpsys_mount.txt
	echo "[*] dumpsys netpolicy" && $SHELL_COMMAND dumpsys netpolicy > "$DUMPSYS_DIR"/dumpsys_netpolicy.txt
    echo "[*] dumpsys netstats" && $SHELL_COMMAND dumpsys netstats > "$DUMPSYS_DIR"/dumpsys_netstats.txt
	echo "[*] dumpsys network_management" && $SHELL_COMMAND dumpsys network_management > "$DUMPSYS_DIR"/dumpsys_network_management.txt
	echo "[*] dumpsys network_score" && $SHELL_COMMAND dumpsys network_score > "$DUMPSYS_DIR"/dumpsys_network_score.txt
	echo "[*] dumpsys notification" && $SHELL_COMMAND dumpsys notification > "$DUMPSYS_DIR"/dumpsys_notification.txt
	echo "[*] dumpsys notification --noredact" && $SHELL_COMMAND dumpsys notification > "$DUMPSYS_DIR"/dumpsys_notification_noredact.txt
	echo "[*] dumpsys package" && $SHELL_COMMAND dumpsys package > "$DUMPSYS_DIR"/dumpsys_package.txt
    echo "[*] dumpsys password_policy" && $SHELL_COMMAND dumpsys password_policy > "$DUMPSYS_DIR"/dumpsys_password_policy.txt
    echo "[*] dumpsys permission" && $SHELL_COMMAND dumpsys permission > "$DUMPSYS_DIR"/dumpsys_permission.txt
	echo "[*] dumpsys phone" && $SHELL_COMMAND dumpsys phone > "$DUMPSYS_DIR"/dumpsys_phone.txt 
	echo "[*] dumpsys power" && $SHELL_COMMAND dumpsys power > "$DUMPSYS_DIR"/dumpsys_power.txt 
  	echo "[*] dumpsys procstats --full-details" && $SHELL_COMMAND dumpsys procstats --full-details > "$DUMPSYS_DIR"/dumpsys_procstats--full-details.txt 
	echo "[*] dumpsys restriction_policy" && $SHELL_COMMAND dumpsys restriction_policy > "$DUMPSYS_DIR"/dumpsys_restriction_policy.txt 
	echo "[*] dumpsys sdhms" && $SHELL_COMMAND dumpsys sdhms > "$DUMPSYS_DIR"/dumpsys_sdhms.txt 
	echo "[*] dumpsys sec_location" && $SHELL_COMMAND dumpsys sec_location > "$DUMPSYS_DIR"/dumpsys_sec_location.txt 
	echo "[*] dumpsys secims" && $SHELL_COMMAND dumpsys secims > "$DUMPSYS_DIR"/dumpsys_secims.txt 
	echo "[*] dumpsys search" && $SHELL_COMMAND dumpsys search > "$DUMPSYS_DIR"/dumpsys_search.txt 
	echo "[*] dumpsys sensorservice" && $SHELL_COMMAND dumpsys sensorservice > "$DUMPSYS_DIR"/dumpsys_sensorservice.txt 
	echo "[*] dumpsys settings" && $SHELL_COMMAND dumpsys settings > "$DUMPSYS_DIR"/dumpsys_settings.txt 
	echo "[*] dumpsys shortcut" && $SHELL_COMMAND dumpsys shortcut > "$DUMPSYS_DIR"/dumpsys_shortcut.txt 
	echo "[*] dumpsys stats" && $SHELL_COMMAND dumpsys stats > "$DUMPSYS_DIR"/dumpsys_stats.txt 
	echo "[*] dumpsys statusbar" && $SHELL_COMMAND dumpsys statusbar > "$DUMPSYS_DIR"/dumpsys_statusbar.txt 
    echo "[*] dumpsys storaged" && $SHELL_COMMAND dumpsys storaged > "$DUMPSYS_DIR"/dumpsys_storaged.txt 
	echo "[*] dumpsys telecom" && $SHELL_COMMAND dumpsys telecom > "$DUMPSYS_DIR"/dumpsys_telecom.txt 
    echo "[*] dumpsys usagestats" && $SHELL_COMMAND dumpsys usagestats > "$DUMPSYS_DIR"/dumpsys_usagestats.txt 
	echo "[*] dumpsys user" && $SHELL_COMMAND dumpsys user > "$DUMPSYS_DIR"/dumpsys_user.txt 
	echo "[*] dumpsys usb" && $SHELL_COMMAND dumpsys usb > "$DUMPSYS_DIR"/dumpsys_usb.txt 
	echo "[*] dumpsys vibrator" && $SHELL_COMMAND dumpsys vibrator > "$DUMPSYS_DIR"/dumpsys_vibrator.txt 
	echo "[*] dumpsys voip" && $SHELL_COMMAND dumpsys voip > "$DUMPSYS_DIR"/dumpsys_voip.txt 
    echo "[*] dumpsys wallpaper" && $SHELL_COMMAND dumpsys wallpaper > "$DUMPSYS_DIR"/dumpsys_wallpaper.txt   
    echo "[*] dumpsys wifi" && $SHELL_COMMAND dumpsys wifi > "$DUMPSYS_DIR"/dumpsys_wifi.txt   
    echo "[*] dumpsys window" && $SHELL_COMMAND dumpsys window > "$DUMPSYS_DIR"/dumpsys_window.txt   

    #Extract appops for every package - See here https://android.stackexchange.com/questions/226282/how-can-i-see-which-applications-is-reading-the-clipboard
    
    mkdir -p "$DUMPSYS_DIR/appops"
    for pkg in $( $SHELL_COMMAND pm list packages | sed 's/package://' )
    do
        echo "[*] appops get $pkg" && $SHELL_COMMAND appops get $pkg > "$DUMPSYS_DIR"/appops/"$pkg"_appops.txt
    done
    
	time_update
	echo -e "[*]\n[*]"    
	echo "[*] DUMPSYS acquisition completed at ${NOW}" | tee -a "$DUMPSYS_LOG_FILE"

	clear && dialog --title "android triage" --msgbox "DUMPSYS acquisition completed at ${NOW}" 6 40
	menu    
}
    
system () {
	set_path
	mkdir -p "$SYSTEM_DIR"
	echo -e "[*]\n[*]"
	echo "[*] This option extracts files from /system" 
	echo -e "[*]\n[*]"
	echo "[*] SYSTEM acquisition started at ${NOW}" | tee "$SYSTEM_LOG_FILE"
	echo -e "[*]\n[*]"		
	echo -e "[*]\n[*]"        
	mkdir -p ${SYSTEM_DIR}/system
	$PULL_COMMAND /system/ ${SYSTEM_DIR}/ >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/app" && $PULL_COMMAND /system/app ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/bin" && $PULL_COMMAND /system/bin ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/cameradata" && $PULL_COMMAND /system/cameradata ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/container" && $PULL_COMMAND /system/container ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/etc" && $PULL_COMMAND /system/etc ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/fake-libs" && $PULL_COMMAND /system/fake-libs ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/fonts" && $PULL_COMMAND /system/fonts ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/framework" && $PULL_COMMAND /system/framework ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/hidden" && $PULL_COMMAND /system/hidden ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/lib" && $PULL_COMMAND /system/lib ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/lib64" && $PULL_COMMAND /system/lib64 ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/media" && $PULL_COMMAND /system/media ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/priv-app" && $PULL_COMMAND /system/priv-app ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/saiv" && $PULL_COMMAND /system/saiv ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/tts" && $PULL_COMMAND /system/tts ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/usr" && $PULL_COMMAND /system/usr ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/vendor" && $PULL_COMMAND /system/vendor ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] /system/xbin" && $PULL_COMMAND /system/xbin ${SYSTEM_DIR}/system >> "$SYSTEM_LOG_FILE"
	echo "[*] Creating TAR file" 
	tar -cvf "$SYSTEM_DIR"/system.tar -C ${SYSTEM_DIR} system >> "$SYSTEM_LOG_FILE" 2>/dev/null
	time_update
	echo -e "[*]\n[*]"    
	echo "[*] SYSTEM acquisition completed at ${NOW}" | tee -a "$SYSTEM_LOG_FILE"
	echo -e "[*]\n[*]"
	echo "[*] Calculating SHA hash" 
	shasum "$SYSTEM_DIR"/system.tar >> "$SYSTEM_LOG_FILE" 2>&1

	clear && dialog --title "android triage" --msgbox "SYSTEM acquisition completed at ${NOW}" 6 40
	menu    
}

adb_backup () {
	set_path
	mkdir -p "$BACKUP_DIR"
	echo -e "[*]\n[*]"
	echo "[*] This option creates an Android Backup by using the command" 
	echo "[*] adb backup -all -shared -system -keyvalue -apk -f backup.ab"
	echo -e "[*]\n[*]"    
	echo "[*] ADB Backup started at ${NOW}" | tee -a "$BACKUP_DIR"/backup_log.txt
	echo -e "[*]\n[*]"      
	echo "[*] Executing 'adb backup -all -shared -system -keyvalue -apk  -f backup.ab'" 
	$BACKUP_COMMAND -all -shared -system -keyvalue -apk -f "$BACKUP_DIR"/backup.ab
	echo -e "[*]\n[*]" 
	time_update	
	echo "[*] ADB Backup completed at ${NOW}" | tee -a "$BACKUP_DIR"/backup_log.txt
	echo -e "[*]\n[*]\n"
	echo "[*] sha1sum of ${BACKUP_DIR}/backup.ab in progress" | tee -a "$BACKUP_DIR"/backup_log.txt
	shasum "${BACKUP_DIR}"/backup.ab | tee -a "$BACKUP_DIR"/backup_log.txt    
    
	clear && dialog --title "android triage" --msgbox "ADB Backup completed at ${NOW}" 6 40
	menu
}

apk () {
	set_path
	mkdir -p "$APK_DIR"
	echo -e "[*]\n[*]"
	echo "[*] This option extractes APK files from DATA partition" 
	echo -e "[*]\n[*]"      
	echo "[*] APK Acquisition started at ${NOW}" | tee "$APK_LOG_FILE"
	echo -e "[*]\n[*]"  
	echo "[*] Extracting APK list"

 	$SHELL_COMMAND pm list packages -f -u > ${APK_DIR}/${ANDROID_ID}_apk_list.txt

	SELECTED_FILE=${APK_DIR}/${ANDROID_ID}_apk_list.txt

	echo "[*] Pulling APK files"
	while read -r line
	do
		line=${line#"package:"}
		target_file=${line%%".apk="*}
		target_file=$target_file".apk"
		IFS='/' read -ra tokens <<<"$target_file"
		apk_type=${tokens[1]}
		app_folder=${tokens[2]}
		app_path=${tokens[3]}
		apk_name=${tokens[4]}

		if [[ ${apk_type} != "system" ]]; then
		    mkdir -p ${APK_DIR}/${apk_type}/${app_folder}/${app_path}
		    $PULL_COMMAND $target_file ${APK_DIR}/${apk_type}/${app_folder}/${app_path}/${apk_name}
		fi
	continue
	done < "$SELECTED_FILE"    

	echo "[*] Creating TAR file" 
	tar -cvf "$APK_DIR"/data_apks.tar -C ${APK_DIR} data >> "$APK_LOG_FILE" 2>/dev/null
    
	echo -e "[*]\n[*]" 
	time_update
	echo "[*] APK Acquisition completed at ${NOW}" | tee -a "$APK_LOG_FILE"
	echo -e "[*]\n[*]" 
	echo "[*] sha1sum of ${APK_DIR}/data_apks.tar in progress" | tee -a "$APK_LOG_FILE"
	shasum "${APK_DIR}"/data_apks.tar | tee -a "$APK_LOG_FILE"

	clear && dialog --title "android triage" --msgbox "APK Acquisition completed at ${NOW}" 6 40
	menu
}

all () {
	set_path
	mkdir -p "$ALL_DIR"
	echo -e "[*]\n[*]"
	echo "[*] This option dump files and folders available without root acces" 
	echo -e "[*]\n[*]"      
	echo "[*] Data Acquisition started at ${NOW}" | tee "$ALL_LOG_FILE"
	echo -e "[*]\n[*]"  
    
    mkdir -p ${ALL_DIR}/filesystem
    
	echo "[*] Extracting APK from /data/ and /vendor/"
	$SHELL_COMMAND pm list packages -f -u > ${ALL_DIR}/${ANDROID_ID}_apk_list.txt

	SELECTED_FILE=${ALL_DIR}/${ANDROID_ID}_apk_list.txt

	echo "[*] Pulling APK files"
	while read -r line
	do
		line=${line#"package:"}
		target_file=${line%%".apk="*}
		target_file=$target_file".apk"
		IFS='/' read -ra tokens <<<"$target_file"
		apk_type=${tokens[1]}
		app_folder=${tokens[2]}
		app_path=${tokens[3]}
		apk_name=${tokens[4]}

		if [[ ${apk_type} != "system" ]]; then
		    mkdir -p ${ALL_DIR}/filesystem/${apk_type}/${app_folder}/${app_path}
		    $PULL_COMMAND $target_file ${ALL_DIR}/filesystem/${apk_type}/${app_folder}/${app_path}/${apk_name}
		fi
	continue
	done < "$SELECTED_FILE" 

	echo "[*] Extracting /system/"
	mkdir -p ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/ ${ALL_DIR}/filesystem/
	$PULL_COMMAND /system/app ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/bin ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/cameradata ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/container ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/etc ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/fake-libs ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/fonts ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/framework ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/hidden ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/lib ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/lib64 ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/media ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/priv-app ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/saiv ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/tts ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/usr ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/vendor ${ALL_DIR}/filesystem/system
	$PULL_COMMAND /system/xbin ${ALL_DIR}/filesystem/system
	mkdir -p $ALL_DIR/filesystem/data/system
    $SHELL_COMMAND cat /data/system/uiderrors.txt > $ALL_DIR/filesystem/data/system/uiderrors.txt

	echo "[*] Extracting /sdcard/"
	mkdir -p ${ALL_DIR}/filesystem/sdcard
	$PULL_COMMAND /sdcard/ ${ALL_DIR}/filesystem/

	echo "[*] Creating TAR file" 
	tar -cvf "$ALL_DIR"/filesystem.tar -C ${ALL_DIR} filesystem >> "$ALL_LOG_FILE" 2>/dev/null
    
	echo -e "[*]\n[*]" 
	time_update
	echo "[*] File System Acquisition completed at ${NOW}" | tee -a "$ALL_LOG_FILE"
	echo -e "[*]\n[*]" 
	echo "[*] sha1sum of ${ALL_DIR}/filesystem.tar in progress" | tee -a "$ALL_LOG_FILE"
	shasum "${ALL_DIR}"/filesystem.tar | tee -a "$ALL_LOG_FILE"

	clear && dialog --title "android triage" --msgbox "file system dump completed at ${NOW}" 6 40
	menu
}

content_provider () {
	set_path
	mkdir -p "$CONTENTPROVIDER_DIR"
	echo -e "[*]\n[*]"
	echo "[*] This option extractes data by using CONTENT PROVIDERS" 
	echo -e "[*]\n[*]"      
	echo "[*] Content Provider Acquisition started at ${NOW}" | tee "$CONTENTPROVIDER_LOG_FILE"
	echo -e "[*]\n[*]"  
	echo "[*] Extracting Content Provider data"
    
    ${SHELL_COMMAND} dumpsys package providers > ${CONTENTPROVIDER_DIR}/content_providers_list.txt

	echo "[*] QUERY CALENDAR CONTENT"
	${SHELL_COMMAND} content query --uri content://com.android.calendar/calendar_entities > ${CONTENTPROVIDER_DIR}/calendar_calendar_entities.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/calendars > ${CONTENTPROVIDER_DIR}/calendar_calendars.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/attendees > ${CONTENTPROVIDER_DIR}/calendar_attendees.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/event_entities > ${CONTENTPROVIDER_DIR}/calendar_event_entities.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/events > ${CONTENTPROVIDER_DIR}/calendar_events.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/properties > ${CONTENTPROVIDER_DIR}/calendar_properties.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/reminders > ${CONTENTPROVIDER_DIR}/calendar_reminders.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/calendar_alerts > ${CONTENTPROVIDER_DIR}/calendar_alerts.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/colors > ${CONTENTPROVIDER_DIR}/calendar_colors.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/extendedproperties > ${CONTENTPROVIDER_DIR}/calendar_extendedproperties.txt
	${SHELL_COMMAND} content query --uri content://com.android.calendar/syncstate > ${CONTENTPROVIDER_DIR}/calendar_syncstate.txt

	echo "[*] QUERY CONTACTS CONTENT"
	${SHELL_COMMAND} content query --uri content://com.android.contacts/raw_contacts > ${CONTENTPROVIDER_DIR}/contacts_raw_contacts.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/directories > ${CONTENTPROVIDER_DIR}/contacts_directories.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/syncstate > ${CONTENTPROVIDER_DIR}/contacts_syncstate.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/profile/syncstate > ${CONTENTPROVIDER_DIR}/contacts_profile_syncstate.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/contacts > ${CONTENTPROVIDER_DIR}/contacts_contacts.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/profile/raw_contacts > ${CONTENTPROVIDER_DIR}/contacts_profile_raw_contacts.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/profile > ${CONTENTPROVIDER_DIR}/contacts_profile.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/profile/as_vcard > ${CONTENTPROVIDER_DIR}/contacts_profile_as_vcard.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/stream_items > ${CONTENTPROVIDER_DIR}/contacts_stream_items.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/stream_items/photo > ${CONTENTPROVIDER_DIR}/contacts_stream_items_photo.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/stream_items_limit > ${CONTENTPROVIDER_DIR}/contacts_stream_items_limit.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/data > ${CONTENTPROVIDER_DIR}/contacts_data.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/raw_contact_entities > ${CONTENTPROVIDER_DIR}/contacts_raw_contact_entities.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/profile/raw_contact_entities > ${CONTENTPROVIDER_DIR}/contacts_profile_raw_contact_entities.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/status_updates > ${CONTENTPROVIDER_DIR}/contacts_status_updates.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/data/phones > ${CONTENTPROVIDER_DIR}/contacts_data_phones.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/data/phones/filter > ${CONTENTPROVIDER_DIR}/contacts_data_phones_filter.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/data/emails/lookup > ${CONTENTPROVIDER_DIR}/contacts_data_emails_lookup.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/data/emails/filter > ${CONTENTPROVIDER_DIR}/contacts_data_emails_filter.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/data/emails > ${CONTENTPROVIDER_DIR}/contacts_data_emails.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/data/postals > ${CONTENTPROVIDER_DIR}/contacts_data_postals.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/groups > ${CONTENTPROVIDER_DIR}/contacts_groups.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/groups_summary > ${CONTENTPROVIDER_DIR}/contacts_groups_summary.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/aggregation_exceptions > ${CONTENTPROVIDER_DIR}/contacts_aggregation_exceptions.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/settings > ${CONTENTPROVIDER_DIR}/contacts_settings.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/provider_status > ${CONTENTPROVIDER_DIR}/contacts_provider_status.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/photo_dimensions > ${CONTENTPROVIDER_DIR}/contacts_photo_dimensions.txt
	${SHELL_COMMAND} content query --uri content://com.android.contacts/deleted_contacts > ${CONTENTPROVIDER_DIR}/contacts_deleted_contacts.txt

	echo "[*] QUERY DOWNLOADS CONTENT"
	${SHELL_COMMAND} content query --uri content://downloads/my_downloads > ${CONTENTPROVIDER_DIR}/downloads_my_downloads.txt
	${SHELL_COMMAND} content query --uri content://downloads/download > ${CONTENTPROVIDER_DIR}/downloads_download.txt

	echo "[*] QUERY EXTERNAL MEDIA CONTENT"
	${SHELL_COMMAND} content query --uri content://media/external/file > ${CONTENTPROVIDER_DIR}/media_external_file.txt
	${SHELL_COMMAND} content query --uri content://media/external/images/media > ${CONTENTPROVIDER_DIR}/media_external_images_media.txt
	${SHELL_COMMAND} content query --uri content://media/external/images/thumbnails > ${CONTENTPROVIDER_DIR}/media_external_images_thumbnails.txt
	${SHELL_COMMAND} content query --uri content://media/external/audio/media > ${CONTENTPROVIDER_DIR}/media_external_audio_media.txt
	${SHELL_COMMAND} content query --uri content://media/external/audio/genres > ${CONTENTPROVIDER_DIR}/media_external_audio_genres.txt
	${SHELL_COMMAND} content query --uri content://media/external/audio/playlists > ${CONTENTPROVIDER_DIR}/media_external_audio_playlists.txt
	${SHELL_COMMAND} content query --uri content://media/external/audio/artists > ${CONTENTPROVIDER_DIR}/media_external_audio_artists.txt
	${SHELL_COMMAND} content query --uri content://media/external/audio/albums > ${CONTENTPROVIDER_DIR}/media_external_audio_albums.txt
	${SHELL_COMMAND} content query --uri content://media/external/video/media > ${CONTENTPROVIDER_DIR}/media_external_video_media.txt
	${SHELL_COMMAND} content query --uri content://media/external/video/thumbnails > ${CONTENTPROVIDER_DIR}/media_external_video_tuhmbnails.txt

	echo "[*] QUERY INTERNAL MEDIA CONTENT"
	${SHELL_COMMAND} content query --uri content://media/internal/file > ${CONTENTPROVIDER_DIR}/media_internal_file.txt
	${SHELL_COMMAND} content query --uri content://media/internal/images/media > ${CONTENTPROVIDER_DIR}/media_internal_images_media.txt
	${SHELL_COMMAND} content query --uri content://media/internal/images/thumbnails > ${CONTENTPROVIDER_DIR}/media_internal_images_thumbnails.txt
	${SHELL_COMMAND} content query --uri content://media/internal/audio/media > ${CONTENTPROVIDER_DIR}/media_internal_audio_media.txt
	${SHELL_COMMAND} content query --uri content://media/internal/audio/genres > ${CONTENTPROVIDER_DIR}/media_internal_audio_genres.txt
	${SHELL_COMMAND} content query --uri content://media/internal/audio/playlists > ${CONTENTPROVIDER_DIR}/media_internal_audio_playlists.txt
	${SHELL_COMMAND} content query --uri content://media/internal/audio/artists > ${CONTENTPROVIDER_DIR}/media_internal_audio_artists.txt
	${SHELL_COMMAND} content query --uri content://media/internal/audio/albums > ${CONTENTPROVIDER_DIR}/media_internal_audio_albums.txt
	${SHELL_COMMAND} content query --uri content://media/internal/video/media > ${CONTENTPROVIDER_DIR}/media_internal_video_media.txt
	${SHELL_COMMAND} content query --uri content://media/internal/video/thumbnails > ${CONTENTPROVIDER_DIR}/media_internal_video_tuhmbnails.txt

	echo "[*] QUERY SETTINGS CONTENT"
	${SHELL_COMMAND} content query --uri content://settings/system > ${CONTENTPROVIDER_DIR}/settings_system.txt
	${SHELL_COMMAND} content query --uri content://settings/system/ringtone > ${CONTENTPROVIDER_DIR}/settings_system_ringtone.txt
	${SHELL_COMMAND} content query --uri content://settings/system/alarm_alert > ${CONTENTPROVIDER_DIR}/settings_system_alarm_alert.txt
	${SHELL_COMMAND} content query --uri content://settings/system/notification_sound > ${CONTENTPROVIDER_DIR}/settings_system_notification_sound.txt
	${SHELL_COMMAND} content query --uri content://settings/secure > ${CONTENTPROVIDER_DIR}/settings_secure.txt
	${SHELL_COMMAND} content query --uri content://settings/global > ${CONTENTPROVIDER_DIR}/settings_global.txt
	${SHELL_COMMAND} content query --uri content://settings/bookmarks > ${CONTENTPROVIDER_DIR}/settings_bookmarks.txt
	${SHELL_COMMAND} content query --uri content://com.google.settings/partner > ${CONTENTPROVIDER_DIR}/google_settings_partner.txt
	${SHELL_COMMAND} content query --uri content://nwkinfo/nwkinfo/carriers > ${CONTENTPROVIDER_DIR}/nwkinfo_carriers.txt 
	${SHELL_COMMAND} content query --uri content://com.android.settings.personalvibration.PersonalVibrationProvider/ > ${CONTENTPROVIDER_DIR}/personal_vibration.txt 
	${SHELL_COMMAND} content query --uri content://settings/system/bluetooth_devices > ${CONTENTPROVIDER_DIR}/bluetooth_devices.txt 
	${SHELL_COMMAND} content query --uri content://settings/system/powersavings_appsettings > ${CONTENTPROVIDER_DIR}/powersavings_appsettings.txt 

	echo "[*] QUERY USER DICTIONARY CONTENT"
	${SHELL_COMMAND} content query --uri content://user_dictionary/words > ${CONTENTPROVIDER_DIR}/user_dictionary_words.txt

	echo "[*] QUERY BROWSER CONTENT"
	${SHELL_COMMAND} content query --uri content://browser/bookmarks > ${CONTENTPROVIDER_DIR}/browser_bookmarks.txt
	${SHELL_COMMAND} content query --uri content://browser/searches > ${CONTENTPROVIDER_DIR}/browser_searches.txt

	echo "[*] QUERY ANDROID BROWSER CONTENT"
	${SHELL_COMMAND} content query --uri content://com.android.browser > ${CONTENTPROVIDER_DIR}/android_browser.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/accounts > ${CONTENTPROVIDER_DIR}/android_browser_accounts.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/accounts/account_name > ${CONTENTPROVIDER_DIR}/android_browser_accounts_account_name.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/accounts/account_type > ${CONTENTPROVIDER_DIR}/android_browser_accounts_account_type.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/accounts/sourceid > ${CONTENTPROVIDER_DIR}/android_browser_accounts_sourceid.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/settings > ${CONTENTPROVIDER_DIR}/android_browser_settings.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/syncstate > ${CONTENTPROVIDER_DIR}/android_browser_syncstate.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/images > ${CONTENTPROVIDER_DIR}/android_browser_images.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/image_mappings > ${CONTENTPROVIDER_DIR}/android_browser_image_mappings.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/bookmarks > ${CONTENTPROVIDER_DIR}/android_browser_bookmarks.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/bookmarks/folder > ${CONTENTPROVIDER_DIR}/android_browser_bookmarks_folder.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/history > ${CONTENTPROVIDER_DIR}/android_browser_history.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/bookmarks/search_suggest_query > ${CONTENTPROVIDER_DIR}/android_browser_bookmarks_search_suggest_query.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/searches > ${CONTENTPROVIDER_DIR}/android_browser_searches.txt
	${SHELL_COMMAND} content query --uri content://com.android.browser/combined > ${CONTENTPROVIDER_DIR}/android_browser_combined.txt
	echo "[*]"
	echo -e "[*]\n[*]"
	clear && dialog --title "android triage" --msgbox "content provider extraction completed at ${NOW}" 6 40
	menu
}

menu () {
	tmpfile=`tmpfile 2>/dev/null` || tmpfile=/tmp/test$$ 
	trap "rm -f $tmpfile" 0 1 2 5 15 
	clear
	dialog --clear --backtitle "Android triage" --title "Android triage $VERSION" --menu "Choose an option:" 16 45 10 \
	1 "Collect basic information" \
	2 "Execute live commands" \
	3 "Execute package manager commands" \
	4 "Execute bugreport,dumpsys,appops" \
	5 "Acquire an ADB Backup" \
	6 "Acquire /system folder" \
	7 "Acquire /sdcard folder" \
	8 "Extract APK files from /data folder" \
	9 "Extract data from content providers" \
	10 "File system dump (no root)" \
	11 "Help" \
	12 "Exit" 2> $tmpfile

	return=$?
	choice=`cat $tmpfile`

	case $return in
          0)
	    #echo "'$choice' chosen"
	    selected ;;
	  1)
	    # Cancel pressed
	    clear && exit 1 ;;
	255)
	    # ESC pressed
	    clear && exit 1 ;;
	esac
}

confirmation () {
	clear
	dialog --title "Confirmation" --yesno  "Option $choice selected. Are you sure to proceed? " 8 30
	answer=$(echo $?)

	#if no
	if [ "$answer" != "0" ]; then
	   menu
	fi
	clear
}

selected () {
	case $choice in
		1)
		  # info_collect
		  confirmation;
		  info_collect;
		  ;;
		2)
		  # live_commands
		  confirmation;
		  live_commands;
		  ;;
		3)
		  # package_manager_commands
		  confirmation;
		  package_manager_commands;
		  ;;
		4)
		  # dumpsys
		  confirmation;
		  dumpsys;
		  ;;
		5)
		  # adb_backup
		  confirmation;
		  adb_backup;
		  ;;
		6)
		  # system
		  confirmation;
		  system;
		  ;;
		7)
		  # sdcard
          confirmation;
		  sdcard;
		  ;;
		8)
		  # apk
          confirmation;
		  apk;
		  ;;
		9)
		  # content provider
          confirmation;
		  content_provider;
		  ;;
		10)
		  # all
          confirmation;
		  all;
		  ;;
        11)
		  # help
          clear && dialog --title "android triage" --msgbox "Android Triage Script\n[ Version \"$VERSION\" ]\n\n" 60 60;
		  menu
		  ;;
		12)
		  # exit
		  clear;
		  exit 1;
		  ;;  
	esac
}

## main ##
check_tools
set_var
check_device
menu
