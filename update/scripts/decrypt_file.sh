#!/bin/sh

if [ "$#" -ne 3 ]; then

        echo "Usage:";
        echo "  $0 <encryptedin> <fileout> <passwordfile>"
		echo ""
        exit 1
fi

OPENSSL=/usr/bin/openssl

E=$1
O=$2
P=$3

if [ "${E}" = "" ] || [ ! -e ${E} ]; then
	echo "Cannot find $F for decryption"
	exit 2;
fi

if [ "${O}" = "" ]; then
	echo "Please pass a destination path"
	exit 3;
fi

if [ "${P}" = "" ] || [ ! -s ${P} ]; then
	echo "Cannot find passwordfile $P"
	exit 4
fi

RESULT=`${OPENSSL} enc -d -aes-256-cbc -md sha256 -salt -in $E -out $O -kfile ${P} 2>&1`
RET=$?

if [ "$RET" -ne 0 ]; then
	#echo "'-md sha256' failed. Trying older '-md md5'"
	RESULT=`${OPENSSL} enc -d -aes-256-cbc -md md5 -salt -in $E -out $O -kfile ${P} 2>&1`
	RET=$?
fi

if [ "$RET" -ne 0 ]; then
	echo "${RESULT}"
fi

exit $RET