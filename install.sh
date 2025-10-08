#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as a root user"
	exit 33
fi

echo "Installing..."
sleep 1
work_dir=$(dirname $(readlink -f "$0"))
source ${work_dir}/monitoring.conf

if [[ -z $HOSTNAME ]]; then
	host_name=""
	while [[ -z "$host_name" ]]; do
		read -p "Hostname: " host_name
		if [[ -z "$host_name" ]]; then
			echo "Hostname is required"
		fi
	done
	sed s/^HOSTNAME=/HOSTNAME=\""$host_name"\"/ -i ${work_dir}/monitoring.conf
fi

if [[ -z $BOT_TOKEN ]]; then
        b_token=""
        while [[ -z $b_token ]]; do
                read -p "Telegram BOT token: " b_token
                if [[ -z $b_token ]]; then
                        echo "BOT token is required"
                fi
        done
        sed s/^BOT_TOKEN=/BOT_TOKEN="$b_token"/ -i ${work_dir}/monitoring.conf
fi

if [[ -z $CHAT_ID ]]; then
        ch_id=""
        while [[ -z $ch_id ]]; do
                read -p "Telegram chat ID: " ch_id
                if [[ -z $ch_id ]]; then
                        echo "chat ID is required"
                fi
        done
        sed s/^CHAT_ID=/CHAT_ID="$ch_id"/ -i ${work_dir}/monitoring.conf
fi

source ${work_dir}/monitoring.conf
echo "Generating systemd unit file..."
sleep 1

cat > /tmp/${UNIT_NAME}.service <<EOF
[Unit]
Description=Devops 5.0 Monitoring service
After=network.target

[Service]
Type=simple
ExecStart=${work_dir}/start.sh
ExecStop=-/usr/bin/rm -f ${work_dir}/running && sleep ${INTERVAL}

[Install]
WantedBy=multiuser.target
EOF

mv /tmp/${UNIT_NAME}.service /etc/systemd/system/${UNIT_NAME}.service

echo "Reloading systemd files"
systemctl daemon-reload
sleep 1

echo "Starting Devops 5.0 Monitoring service"
systemctl enable --now ${UNIT_NAME}.service
sleep 1

echo "Starting Devops 5.0 Monitoring service has been installed successfully"


