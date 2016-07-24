#! /bin/bash

## cleanup for client

IP_CLIENT=$1

# filter what is used: systemV init or systemd
SYSTEM_MANAGER=`ps -p 1 | tail -n 1 | grep -oE '[^ ]+$'`

# stop VPN service dependinding on system manager
if [ $SYSTEM_MANAGER = "init" ]; then
  service openvpn stop client.conf
else
  systemctl stop openvpn@client
fi

# Restart with clean configuration
rm -rf /var/lib/slenkins/tests-openvpn/tests-client/data/EasyRSA-3.0.1
rm -rf /etc/openvpn/*


ip link show tun0
if [ $? -eq 0 ]
then
        echo "TUNNEL after CLEAN_UP not REMOVED!"
        exit 2
else
        echo "CLEANUP TUN OK !"  
fi
