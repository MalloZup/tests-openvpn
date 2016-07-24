#! /bin/bash
#
# Testing the tunnel from client side, for basic and CA configuration
set -e

IP_VPN_CLIENT=172.19.0.2
IP_VPN_SERVER=172.19.0.1
# /etc/openvpn/SUSE is created for CA openvpn tests
SUSE_CA=/etc/openvpn/SUSE
SERV_IP6=2001:db8:0:123::1
IP_PROTO_TYPE=$1


# test if tunnel is active then make tests
while ! ip a l tun0 | grep inet; do 
echo "tunnnel still not active"
sleep 3
done

echo "++++++++++++"
echo "tunnel CLIENT is now active!"
echo "++++++++++++"

if [[ $IP_PROTO_TYPE == "ip6" ]]
then
	TEST=IP6
	ping6 -c 3 -I tun0 $SERV_IP6
	echo "ping successful"
	journalctl -u openvpn@server -fn > /tmp/openvpn-client$TEST &
else
#  check for CA or BASIC testing 
	if [ -d "$SUSE_CA" ]; then
		TEST=SSL
		# Now test we can ping through it
		ping -c 3 -I tun0 10.8.0.1
		echo "ping successful"
		journalctl -u openvpn@server -fn > /tmp/openvpn-client$TEST &

		else 
		TEST=BASIC
		ping -c 3 -I tun0 $IP_VPN_SERVER
		echo "ping successful"
		journalctl -u openvpn@server -fn > /tmp/openvpn-client$TEST &
	fi
fi
