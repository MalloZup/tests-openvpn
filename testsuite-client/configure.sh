#! /bin/bash
#
# Configuring openvpn on client side

set -e

IP_SERVER=$1
IP_VPN_CLIENT=172.19.0.2
IP_VPN_SERVER=172.19.0.1
## this variable is for debugging openvpn
if [ -z "$2" ]; then DEBUG_MODE=NO; else DEBUG_MODE=$2; fi
log=/var/log/openvpndebug.log

# filter what is used: systemV init or systemd
SYSTEM_MANAGER=`ps -p 1 | tail -n 1 | grep -oE '[^ ]+$'`


cat > /etc/openvpn/client.conf <<EOF
remote $IP_SERVER
dev tun
ifconfig $IP_VPN_CLIENT $IP_VPN_SERVER
secret secret.key
cipher AES-256-CBC
EOF
echo "Configuration file created:"

if [ $DEBUG_MODE = "DEBUG" ]; then
	#   debug_mode
	openvpn --config /etc/openvpn/client.conf  --verb 6 --secret /etc/openvpn/secret.key > $log &
	echo "started in debug mode"
else
	#   normal_mode as service
	# start vpn_service depends on Sys_Manager
	if [ $SYSTEM_MANAGER = "init" ]; then
            service openvpn start client.conf
        else
            systemctl start openvpn@client
        fi
	echo "openvpn service started."
fi
