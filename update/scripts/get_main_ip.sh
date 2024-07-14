#!/bin/sh
#Script to return the main useable device IP address of the box, used for main outbound connections.
#on a LAN, this should match your directadmin.conf lan_ip setting.
#for normal servers, this will likely return your license IP (usually)
#Will also be the default IP that exim sends email through.
OS=`uname`
if [ "${OS}" = "FreeBSD" ]; then
	/sbin/ifconfig | grep inet | grep -m1 broadcast | awk '{ print $2; }'
	RET=$?
else
	IP=`/sbin/ip a | grep inet | grep -m1 brd | awk '{ print $2; };' | cut -d/ -f1`
	RET=$?
	
	if [ "${IP}" = "" ]; then
		#IP=`/sbin/ip a | grep 'inet ' | grep -v 127.0.0.1 | head -n1 | awk '{ print $2; };' | cut -d/ -f1`
		IP=`ip route get 8.8.8.8 | head -1 | grep -o 'src [^ ]*' | awk '{print $2}'`
		RET=$?
	fi
	echo ${IP}
fi

exit $RET
