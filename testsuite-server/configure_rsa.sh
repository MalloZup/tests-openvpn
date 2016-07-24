#! /bin/bash
#
# Configuring openvpn on server side

set -e

# for scp files to client
IP_CLIENT=$1
PROTO_IP_TYPE=$2
## PKI_CA VARIABLES
UNIQUE_SERVER_NAME=server_pascal
CA=/CA/EasyRSA-3.0.1

#  filter what is used: INITD or SYSTEMD 
SYSTEM_MANAGER=`ps -p 1 | tail -n 1 | grep -oE '[^ ]+$'`


## Server config. run after client conf


# Extract tar
mkdir /etc/openvpn/SUSE
cd /var/lib/slenkins/tests-openvpn/tests-server/data/
# check if ip6 or ip4
if [ $PROTO_IP_TYPE == "ip4" ] ; then cp server.conf /etc/openvpn/; else cp server-ip6.conf /etc/openvpn/server.conf; fi

tar xzf EasyRSA-3.0.1.tgz
cp -r EasyRSA-3.0.1 /CA/

# CA build    
cd $CA    
./easyrsa init-pki &>/dev/null
echo -e "\n" | ./easyrsa build-ca nopass &>/dev/null

## BUILD SERVER KEYS

cd /var/lib/slenkins/tests-openvpn/tests-server/data/EasyRSA-3.0.1/
./easyrsa init-pki &>/dev/null
echo -e "\n" |	./easyrsa gen-req $UNIQUE_SERVER_NAME nopass &>/dev/null
./easyrsa gen-dh &>/dev/null 
mv pki/reqs/server_pascal.req /CA/import/

### certs keys for the openvpn server
cp pki/private/server_pascal.key /etc/openvpn/SUSE/
cp pki/dh.pem  /etc/openvpn/SUSE/
openvpn --genkey --secret ta.key &>/dev/null 
cp ta.key /etc/openvpn/SUSE/

###### SIGN with CA the client and server keys 
cd $CA
./easyrsa import-req /CA/import/server_pascal.req blaise
./easyrsa import-req /CA/import/client_leibniz.req gottfried
echo  "yes" | ./easyrsa sign-req client gottfried &>/dev/null
echo  "yes" | ./easyrsa sign-req server blaise &>/dev/null

### copy certificates for server on SUSE directory conf
# ca.crt, server.crt, dh2048m, server.key, ta.key

cp $CA/pki/issued/blaise.crt /etc/openvpn/SUSE/
cp $CA/pki/ca.crt /etc/openvpn/SUSE/

# write the ip6 adress for ip6 tunnel testing to client FIXME: this is a workaround, cancel it when IP6_SERVER slenkins-variable is done.
IP6SERVER=`ip -6 addr show eth0 | sed -n '2p' | awk '{print $2}' | rev | cut -c 4- | rev`
echo $IP6SERVER >/tmp/ip6server.txt
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/ip6server.txt  $IP_CLIENT:/tmp/ip6server.txt &>/dev/null
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP_CLIENT 'echo "$(cat /tmp/ip6server.txt) pascal6" >>/etc/hosts'


### cp cert to /etc/openvpn  that  client need.
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $CA/pki/ca.crt  $IP_CLIENT:/etc/openvpn/SUSE/ &>/dev/null
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /etc/openvpn/SUSE/ta.key  $IP_CLIENT:/etc/openvpn/SUSE/ &>/dev/null
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $CA/pki/issued/gottfried.crt  $IP_CLIENT:/etc/openvpn/SUSE/ &>/dev/null

ls -l /etc/openvpn/SUSE/

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++*****"
echo " PKI/CA/Certificate setup done ! "
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++****"
if [ $SYSTEM_MANAGER = "init" ]; then service openvpn start server.conf; else systemctl start openvpn@server; fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++*****"
echo " Openvpn TLS Tunnel started ! "
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++****"
