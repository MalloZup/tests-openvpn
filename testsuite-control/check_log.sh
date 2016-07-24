#! /bin/bash
MACHINE=$1

check_log ()
{
  error_type="$1"
  file_name="$2"
  package="$3"
  debug_log="$file_name.debug"
  echo -n "TEST: searching for ${error_type} errors in ${file_name} log file: "
  # insensitive, context lines 10, line number in file
  grep -i $error_type -C 10 -n $file_name > $debug_log
  if [ $? -eq 0 ]; then
    echo "FOUND ERROR $error_type"
    cat $debug_log
    echo "PACKAGE VERSION:"
    rpm -qv $package
    exit 2
  else
    echo "OK"
  fi
}


SUITE='/var/lib/slenkins/tests-squid/tests-proxy'

echo "++++++++++++++++++++++++"
echo "+ CHECKING THE LOG $MACHINE+"
echo "++++++++++++++++++++++++"

for error_type in fatal error warning security; do
   for TEST in SSL IP6 BASIC; do
 	 check_log $error_type /tmp/openvpn-$MACHINE$TEST openvpn
	done
done
