#! /bin/bash

source /usr/lib/slenkins/testlib/control-functions.sh

rc=0
suite="/var/lib/slenkins/tests-openvpn"


# ===================================================================================== #
#                                      HELPER FUNCTIONS                                 #
# ===================================================================================== #

function  configure_easy_rsa_v3 {
    jlogger.sh testsuite -i configuration.RSA.openvpn -t "Configuring openvpn for RSA"
    twopence_command -b $TARGET_SERVER "mkdir -p /CA/import"

    jlogger.sh testcase -i client.configuration.RSA.openvpn -t "Configuring openVPN server RSA-easy-Key"
    twopence_command -b $TARGET_CLIENT "$suite/tests-client/bin/configure_rsa.sh $INTERNAL_IP_SERVER $1"

    jlogger.sh testcase -i server.configuration.RSA.openvpn -t "Configuring openVPN server RSA-easy-Key"
    twopence_command -b -t 10000 $TARGET_SERVER "$suite/tests-server/bin/configure_rsa.sh $INTERNAL_IP_CLIENT $1"

    jlogger.sh testcase -i openvpn.client.file.configuration -t "Client postconfiguration, set file and start tunnel"
    twopence_command -b $TARGET_CLIENT "$suite/tests-client/bin/post_configure_rsa.sh $INTERNAL_IP_SERVER"

    jlogger.sh endsuite
    [ $rc -eq 0 ] || exit $rc
}

## Clean up the tunnel on server and on client and verify that everything is cleaned
function clean_up { 
    # Server
    jlogger.sh testsuite -i delete.tunnel.opevpn -t "delete tunnel"

    jlogger.sh testcase -i server.test.openvpn -t "cleanup tun server"
    twopence_command -b $TARGET_SERVER "$suite/tests-server/bin/cleanup.sh"
    if [ $? -eq 0 ]; then jlogger.sh success; else rc=3; jlogger.sh failure; fi

    # Client
    jlogger.sh testcase -i client.test.openvpn -t "cleanup tun server"
    twopence_command -b $TARGET_CLIENT "$suite/tests-client/bin/cleanup.sh"
    if [ $? -eq 0 ]; then jlogger.sh success; else rc=3; jlogger.sh failure; fi

    jlogger.sh endsuite
    [ $rc -eq 0 ] || exit $rc
}

function testing_tun {
    jlogger.sh testsuite -i test.openvpn -t "Testing the tunnel"

    jlogger.sh testcase -i client.test.openvpn -t "Test from client side"
    twopence_command -b $TARGET_CLIENT "$suite/tests-client/bin/test.sh $1"
    if [ $? -eq 0 ]; then jlogger.sh success; else rc=3; jlogger.sh failure; fi

    jlogger.sh testcase -i server.test.openvpn -t "Test from server side"
    twopence_command -b $TARGET_SERVER "$suite/tests-server/bin/test.sh $1"
    if [ $? -eq 0 ]; then jlogger.sh success; else rc=3; jlogger.sh failure; fi

    jlogger.sh endsuite
         [ $rc -eq 0 ] || exit $rc
}

function configure_basic_tun {
    # There is only one variable to pass to configure.sh script: DEBUG.
    # Debug variable is for debugging openvpn, in configuration file.
    # It adds openvpn --verb and runs openvpn not in standard way, but as a service. 

    jlogger.sh testsuite -i configuration.openvpn -t "Configuring openvpn"
    jlogger.sh testcase -i server.configuration.openvpn -t "Configuring openVPN server"
    twopence_command -b $TARGET_SERVER "$suite/tests-server/bin/configure.sh $INTERNAL_IP_CLIENT "
    if [ $? -eq 0 ]; then jlogger.sh success; else rc=2; jlogger.sh failure; fi

    jlogger.sh testcase -i client.configuration.openvpn -t "Configuring openVPN client"
    twopence_command -b $TARGET_CLIENT "$suite/tests-client/bin/configure.sh $INTERNAL_IP_SERVER "
    if [ $? -eq 0 ]; then jlogger.sh success; else rc=2; jlogger.sh failure; fi

    jlogger.sh endsuite
    [ $rc -eq 0 ] || exit $rc
}


# ===================================================================================== #
#                                      MAIN                                             #
# ===================================================================================== #

############################## PRECONFIGURATION ###############################
# Common preconfiguration for both tests

jlogger.sh testsuite -t "Preconfiguration for both client and server"

# Kernel module prerequisites.
jlogger.sh testcase -i tun.preconfiguration.openvpn -t "Loading tun module Server"

twopence_command -b "$TARGET_SERVER" "modprobe tun --first-time"
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

jlogger.sh testcase -i tun.preconfiguration.openvpn -t "Loading tun module Client"
twopence_command -b "$TARGET_CLIENT" "modprobe tun --first-time"
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

# Allow SSH from server to client
jlogger.sh testcase -i keys.preconfiguration.openvpn -t "Exchanging SSH keys server->client"

ssh_access root server root client 
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

jlogger.sh testcase -i keys.preconfiguration.openvpn -t "Exchanging SSH keys client->server"
ssh_access root client root server
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

# Set hostname. pascal = server, leibniz = client. 
jlogger.sh testcase -i hostname.setting -t "SetHostname Pascal to server"
twopence_command -b "$TARGET_SERVER" "echo "pascal" > /etc/hostname"
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

jlogger.sh testcase -i hostname.setting -t "SetHostname Leibniz to client"
twopence_command -b "$TARGET_CLIENT" "echo "leibniz" > /etc/hostname"
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

# Make pascal and leibniz knows each other, by name and not only by IP 
jlogger.sh testcase -i hosts.settings -t "set hosts settings for server "
twopence_command -b "$TARGET_SERVER" "echo "$INTERNAL_IP_CLIENT\ leibniz" >> /etc/hosts"
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

jlogger.sh testcase -i hosts.settings -t "set hosts settings for client"
twopence_command -b "$TARGET_CLIENT" "echo "$INTERNAL_IP_SERVER\ pascal" >> /etc/hosts"
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

jlogger.sh testcase -i hosts.settings -t "ping from server new host"
twopence_command -b "$TARGET_SERVER" "ping -c3 leibniz &>/dev/null"
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

jlogger.sh testcase -i hosts.settings -t "ping from client new host"
twopence_command -b "$TARGET_CLIENT" "ping -c3 pascal &>/dev/null"
if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi

jlogger.sh endsuite
[ $rc -eq 0 ] || exit $rc


##################### BASIC CONFIGURATION #############################
configure_basic_tun
testing_tun
clean_up


##################### TEST WITH RSA AND IPV4 ##########################
echo "Testing Tunnel with IP4 !" 
configure_easy_rsa_v3 "ip4"
testing_tun "ip4"
clean_up


##################### TEST WITH RSA AND IPV6 ##########################
echo " SKIPPING THE TEST FOR IP6 (UNTIL CLOUD IS READY) !" 
# configure_easy_rsa_v3 "ip6"
# twopence_command -b "$TARGET_CLIENT" "ping6 -c3 -I eth0 pascal6"
# if [ $? -eq 0 ]; then jlogger.sh success; else rc=1; jlogger.sh failure; fi
# testing_tun "ip6"
# clean_up


##################### CHECK LOGS ON CLIENT AND SERVER #################
jlogger.sh testsuite -i checklog.server.client -t  "Checking Log for Client and Server"
jlogger.sh testcase -i check.log.server -t "check log for server"
## "server" or "client" is needed in lower case for passing it to the check_log script
twopence_command -b $TARGET_SERVER "$suite/tests-server/bin/check_log.sh "server""
if [ $? -eq 0 ]; then jlogger.sh success; else rc=2; jlogger.sh failure; fi

jlogger.sh testcase -i checklog.client -t "checking log for client"
twopence_command -b $TARGET_CLIENT "$suite/tests-client/bin/check_log.sh "client" "
if [ $? -eq 0 ]; then jlogger.sh success; else rc=2; jlogger.sh failure; fi

jlogger.sh endsuite
[ $rc -eq 0 ] || exit $rc
