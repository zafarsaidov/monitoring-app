number_cpu_cores=$(nproc)
cpu_in_alarm=0
cpu_peak_count=0

cpu_check(){
	cpu_overall_load=$(uptime | awk '{ print $(NF-2) }' | tr -d ',' | tr -d '.')
	#cpu_load_percentage=$(($cpu_overall_load/$number_cpu_cores))
	cpu_load_percentage=$(echo "$cpu_overall_load/$number_cpu_cores" | bc) # Second method for calculating
	echo $cpu_load_percentage
	if [[ $cpu_load_percentage -ge ${CPU_LIMIT} && ${cpu_in_alarm} -eq 0 ]]; then
		cpu_peak_count=$(($cpu_peak_count+1))
		if [[ $cpu_peak_count -ge $CPU_LIMIT_PEAK_COUNT ]]; then
			message="🔥️️️️🔥️️️️ Alert 🔥🔥 %0A%0AHostname: ${HOSTNAME} %0A%0ACPU is in fire: ${cpu_load_percentage}%"
			curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text="${message}" > /dev/null
			cpu_in_alarm=1
			cpu_peak_count=0
		fi
	fi
	if [[ $cpu_load_percentage -lt ${CPU_LIMIT} && ${cpu_in_alarm} -eq 1 ]]; then
		message="✅✅ Resolved ✅✅ %0A%0AHostname: ${HOSTNAME} %0A%0ACPU is in relax: ${cpu_load_percentage}%"
		curl -s -X POST https://api.telegram.org/bot${BOT_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text="${message}" > /dev/null
		cpu_in_alarm=0
	fi
}
