#! /bin/bash
#
# Configuring openvpn on server side

set -e
IP_CLIENT=$1
IP_VPN_CLIENT=172.19.0.2
IP_VPN_SERVER=172.19.0.1
#  filter what is used: INITD or SYSTEMD 
SYSTEM_MANAGER=`ps -p 1 | tail -n 1 | grep -oE '[^ ]+$'`
## this variable is for debugging openvpn
if [ -z "$2" ]; then DEBUG_MODE=NO; else DEBUG_MODE=$2; fi
log=/var/log/openvpndebug.log


# this is how openvpn create a tunnel given the simple conf
# /bin/ip link set dev tun0 up mtu 1500
# /bin/ip addr add dev tun0 local 192.168.1.120 peer 192.168.2.110





openvpn --genkey --secret /etc/openvpn/secret.key
echo "Shared secret created"

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /etc/openvpn/secret.key $IP_CLIENT:/etc/openvpn/
echo "Shared secret copied to client"

cat > /etc/openvpn/server.conf <<EOF
dev tun
ifconfig $IP_VPN_SERVER $IP_VPN_CLIENT
secret secret.key
cipher AES-256-CBC
EOF
echo "Configuration file created:"
cat /etc/openvpn/server.conf

#   debug_mode
if [ $DEBUG_MODE = "DEBUG" ]; then
	openvpn --config /etc/openvpn/server.conf  --verb 6 --secret /etc/openvpn/secret.key > $log &
	echo "++++++++++ openvpn started with debug mode ++++++++++++++"
else
	#  THIS is STANDARD way to start opevpn
	# start vpn_service depends on Sys_Manager
	if [ $SYSTEM_MANAGER = "init" ]; then service openvpn start server.conf; else systemctl start openvpn@server; fi
	echo "openvpn service started."
fi

