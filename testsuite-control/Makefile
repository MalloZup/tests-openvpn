SUITE = ${DESTDIR}/var/lib/slenkins/tests-openvpn

all:

install: nodes run.sh
	mkdir -p ${SUITE}/tests-control/bin
	mkdir -p ${SUITE}/tests-server/data
	mkdir -p ${SUITE}/tests-server/bin
	mkdir -p ${SUITE}/tests-client/bin
	mkdir -p ${SUITE}/tests-client/data
	mkdir -p ${SUITE}/tests-client/data
	cp nodes ${SUITE}/tests-control/
	cp run.sh ${SUITE}/tests-control/bin/
	cp check_log.sh ${SUITE}/tests-server/bin/
	cp check_log.sh ${SUITE}/tests-client/bin/
	
	cp data/EasyRSA-3.0.1.tgz ${SUITE}/tests-server/data
	cp data/EasyRSA-3.0.1.tgz ${SUITE}/tests-client/data
	# server/client openvnp conf-file
	cp data/client.conf ${SUITE}/tests-client/data
	cp data/server.conf ${SUITE}/tests-server/data
	cp data/client-ip6.conf ${SUITE}/tests-client/data
	cp data/server-ip6.conf ${SUITE}/tests-server/data
