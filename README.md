## openvpn-testsuite

Author: Dario Maiocchi dmaiocchi@suse.com


Testcases/scenarios:

1) basic tunnel with secret key 
2) RSA/CA tunnel 
3) IP6 RSA/CA tunnel 

## 1) basic_tunnel use in run.sh this files, in order:
testsuite-client
	- configure.sh, test.sh , cleanup.sh

testsuite-server
	- configure.sh, test.sh, cleanup.sh

## 2) RSA/CA tunnel use in run.sh this files, in order:
testsuite-client
	-configure_rsa.sh, post_configure_rsa.sh, test.sh, cleanup.sh

testsuite-server
	-configure_rsa.sh, test.sh, cleanup.sh

this both scenario share cleanup and testing function in run.sh. 

## 3) IP6 tunnel use RSA/CA configuration and is scalable. no big modification.


TODO:

* running differents instances openvpn daemon on server. Like 3 or 5 tunnels on same server also then other clients 3-5.

* other adv. configuration ( like fallback server)

* convert to susetest
