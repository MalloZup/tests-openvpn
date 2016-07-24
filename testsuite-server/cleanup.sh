#! /bin/bash

#cleanup for server

IP_CLIENT=$1
#  filter what is used: INITD or SYSTEMD 
SYSTEM_MANAGER=`ps -p 1 | tail -n 1 | grep -oE '[^ ]+$'`

# stop vpn_service depends on Sys_Manager
rm -rf /var/lib/slenkins/tests-openvpn/tests-server/data/EasyRSA-3.0.1
rm -rf /CA
rm -rf /etc/openvpn/*

if [ $SYSTEM_MANAGER = "init" ]; then service openvpn stop server.conf; else systemctl stop openvpn@server; fi


ip link show tun0
if [ $? -eq 0 ]
then 
	echo "TUNNEL after CLEAN_UP not REMOVED!"
	exit 2 
else 
	echo "CLEANUP TUN OK !"	
fi
