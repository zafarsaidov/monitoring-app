#!/bin/bash

script_folder=$(dirname $(readlink -f "$0"))
script_running_state_file="${script_folder}/running"

source ${script_folder}/monitoring.conf
source ${script_folder}/functions/cpu.sh

init(){
	touch "$script_running_state_file"
}

init

while [[ -f "$script_running_state_file" ]]; do
	cpu_check
	sleep "${INTERVAL}"
done
