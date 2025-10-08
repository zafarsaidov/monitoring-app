#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "Sctipt must be run as a root user"
	exit 33
fi

work_dir=$(dirname $(readlink -f "$0"))
source ${work_dir}/monitoring.conf

echo "Stoping service..."
systemctl stop ${UNIT_NAME}.service
sleep 1

echo "Uninstalling..."
sleep 1
rm -f /etc/systemd/system/${UNIT_NAME}.service
systemctl daemon-reload

echo "Devops 5.0 Monitoring service has been uninstalled successfully"

