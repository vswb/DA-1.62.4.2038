#!/bin/sh

DA_DIR=/usr/local/directadmin
DA_BIN=${DA_DIR}/directadmin

NAMED_CONF=""
SERVICE_NAME=named
if [ -s ${DA_DIR}/conf/directadmin.conf ] && [ -x ${DA_BIN} ]; then
	NAMED_CONF=`${DA_BIN} c | grep ^namedconfig= | cut -d= -f2`
	NAMED_OVERRIDE=`${DA_BIN} c | grep ^named_service_override= | cut -d= -f2`
	if [ "${NAMED_OVERRIDE}" != "" ]; then
		SERVICE_NAME=${NAMED_OVERRIDE}
	fi
fi

if [ "${NAMED_CONF}" = "" ] || [ ! -s "$NAMED_CONF" ]; then
	NAMED_CONF=/etc/named.conf
	OS=`uname`
	if [ "$OS" = "FreeBSD" ]; then
		NAMED_CONF=/etc/namedb/named.conf
	fi
	if [ -s /etc/debian_version ]; then
		NAMED_CONF=/etc/bind/named.conf
	fi
fi

if [ ! -s $NAMED_CONF ]; then
	echo "Cannot find $NAMED_CONF to check";
	exit 1;
fi

if grep -m1 -q allow-transfer ${NAMED_CONF}; then
	#echo "Skipping allow-transfer chcek on ${NAMED_CONF}. allow-transfer already present.";
	exit 0;
fi

OPTIONS_CONF=$NAMED_CONF
HAVE_OPTIONS_AREA=`grep -c '^options {' ${OPTIONS_CONF}`

for i in `grep -E '^[[:space:]]*include ' ${NAMED_CONF} | cut -d\" -f2`; do
{
	if [ "$i" = "" ] || [ ! -s "$i" ]; then
		continue;
	fi
	
	if grep -m1 -q allow-transfer ${i}; then
		#echo "Skipping allow-transfer chcek on ${i}. allow-transfer already present.";
		exit 0;		
	fi	

	if [ "${HAVE_OPTIONS_AREA}" -eq 0 ]; then
		HAVE_OPTIONS_AREA=`grep -c '^options {' $i`
		if [ "${HAVE_OPTIONS_AREA}" -eq 0 ]; then
			continue;
		fi
		OPTIONS_CONF=$i
	fi
};
done;

if [ "${HAVE_OPTIONS_AREA}" -eq 0 ]; then
	echo "Could not find options section in the $NAMED_CONF or any of it's include files";
	exit 2;
fi

if ! grep -m1 -q allow-transfer ${OPTIONS_CONF}; then
	perl -pi -e 's|options \{|options \{\n\tallow-transfer \{ none; \};|g' ${OPTIONS_CONF}
	echo "Added 'allow-transfer { none; };' to ${OPTIONS_CONF}"
	echo "action=${SERVICE_NAME}&value=reload" >> ${DA_DIR}/data/task.queue
fi

exit 0;
