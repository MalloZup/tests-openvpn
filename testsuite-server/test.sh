#! /bin/bash
#
# Testing the tunnel from server side.

set -e

IP_VPN_CLIENT=172.19.0.2
IP_VPN_SERVER=172.19.0.1
SUSE_CA=/etc/openvpn/SUSE
CLIENT01=10.8.0.6
CLIENT01_IP6=2001:db8:0:123::1000
IP_PROTO_TYPE=$1




while ! ip a l tun0 | grep inet; do
echo "tunnnel still not active"
sleep 3
done

echo "++++++++++++"
echo "tunnel SERVER is now active!"
echo "++++++++++++"

## test for ip6 or ip4
if [[ $IP_PROTO_TYPE= = "ip6" ]]
then
	TEST=IP6
	ping6 -c 3 -I tun0 $CLIENT01_IP6
	echo "ping successful"
	journalctl -u openvpn@server -fn > /tmp/openvpn-server$TEST &
else
	echo 
	if [ -d "$SUSE_CA" ]; then
		TEST=SSL
		# Now test we can ping through it
		ping -c 3 -I tun0 $CLIENT01
		echo "ping successful"
		journalctl -u openvpn@server -fn > /tmp/openvpn-server$TEST &
	else 
		TEST=BASIC
		ping -c 3 -I tun0 $IP_VPN_SERVER
		journalctl -u openvpn@server -fn > /tmp/openvpn-server$TEST &
		
	fi

fi
