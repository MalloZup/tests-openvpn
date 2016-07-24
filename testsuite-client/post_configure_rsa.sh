#! /bin/bash

##client post:configuration

SYSTEM_MANAGER=`ps -p 1 | tail -n 1 | grep -oE '[^ ]+$'`

# start tunnel
if [ $SYSTEM_MANAGER = "init" ]; then
  service openvpn start client.conf
else
  systemctl start openvpn@client
fi
