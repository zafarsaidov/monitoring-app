storage_alarm_state=0

storage_check() {
	for mnt_pts in $MOUNTPOINTS; do
		storage_used_percentage=$(df -h "$mnt_pts" | tail -n 1 | awk '{ print $(NF-1) }' | tr -d "%")
		if [[ $storage_used_percentage -ge $STORAGE_LIMIT && $storage_alarm_state -eq 0 ]]; then
			message="🔥️️️️🔥️️️️ Alert 🔥🔥 %0A%0AHostname: ${HOSTNAME} %0A%0AStorage is filled: ${storage_used_percentage}% %0A%0AMountpoint: $mnt_pts"
			curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text="${message}" > /dev/null
			storage_alarm_state=1
		fi
		if [[ $storage_used_percentage -lt $STORAGE_LIMIT && $storage_alarm_state -eq 1 ]]; then
			message="✅✅ Resolved ✅✅ %0A%0AHostname: ${HOSTNAME} %0A%0AStorage is normal: ${storage_used_percentage}% %0A%0AMountpoint: $mnt_pts"
                        curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text="${message}" > /dev/null
                        storage_alarm_state=0
		fi
	done
}

