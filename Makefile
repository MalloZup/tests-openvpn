SUITE  = ${DESTDIR}/var/lib/slenkins/tests-openvpn

all:

install: README
	mkdir -p ${SUITE}
	cp README ${SUITE}/
	make -C testsuite-control install
	make -C testsuite-client install
	make -C testsuite-server install

