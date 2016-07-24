#! /bin/bash
#
# Configuring openvpn on client side

set -e

IP_SERVER=$1
PROTO_IP_TYPE=$2
# preserve same adress for configurations
IP_VPN_CLIENT=172.19.0.2
IP_VPN_SERVER=172.19.0.1
UNIQUE_CLIENT_NAME=client_leibniz
DATADIR=/var/lib/slenkins/tests-openvpn/tests-client/data
PKIDIR=$DATADIR/EasyRSA-3.0.1/pki


echo "+++++++++++++++++++++++++++++++++++"
echo "building keys for client"
echo "+++++++++++++++++++++++++++++++++++"
## build keys
cd $DATADIR/

if [ $PROTO_IP_TYPE == "ip4" ] ; then cp client.conf /etc/openvpn/; else cp client-ip6.conf /etc/openvpn/client.conf; fi

tar xzf EasyRSA-3.0.1.tgz
cd EasyRSA-3.0.1/
./easyrsa init-pki &>/dev/null


echo   | ./easyrsa gen-req $UNIQUE_CLIENT_NAME nopass
echo "+++++++++++++++++++++++++++++++++++"
echo "client key generated"
echo "+++++++++++++++++++++++++++++++++++"

mkdir /etc/openvpn/SUSE
cp $PKIDIR/private/client_leibniz.key /etc/openvpn/SUSE
## copy the entity name request to CA
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $PKIDIR/reqs/client_leibniz.req $IP_SERVER:/CA/import/ &>/dev/null

echo "+++++++++++++++++++++++++++++++++++"
echo "client key copied to server"
echo "+++++++++++++++++++++++++++++++++++"


## /etc/openvpn/ 3 files  ca.crt client1.crt  client1.key 
