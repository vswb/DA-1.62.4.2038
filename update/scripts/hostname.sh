#!/bin/bash

if [ $# -lt "1" ]
then
        echo "Usage: $0 <hostname> (<ip>)";
        exit 1;
fi
DIRECTADMIN_BIN=/usr/local/directadmin/directadmin
DIRECTADMIN_CONF=/usr/local/directadmin/conf/directadmin.conf
IP="127.0.0.1";
SETUP=/usr/local/directadmin/scripts/setup.txt
OS=`uname`
ETH_DEV=eth0
if [ -s $SETUP ]; then
	IP=`grep -m1 '^ip=' $SETUP | cut -d= -f2`;
else
	if [ "${OS}" = "FreeBSD" ]; then
		IP=`/sbin/ifconfig | head -n3 | grep 'inet ' | cut -d\  -f2`;
	else
		if [ -s $DIRECTADMIN_CONF ] && [ -x $DIRECTADMIN_BIN ]; then
			ETH_DEV=`$DIRECTADMIN_BIN c | grep '^ethernet_dev=' | cut -d= -f2`
		fi
		IP=`ip addr show $ETH_DEV | grep -m1 'inet ' | awk '{print $2}' | cut -d/ -f1`
		if [ -z ${IP} ]; then
			IP=`/sbin/ifconfig $ETH_DEV | grep 'inet ' | head -n1 | awk '{print $2}' | cut -d: -f2`
		fi
		if [ "${IP}" = "127.0.0.1" ] || [ "${IP}" = "" ]; then
			IP=`ip route get 1 | awk '{print $7}' | head -n1`
		fi
	fi
fi

if [ $# -gt "1" ]
then
	IP=$2;
fi

if [ "${OS}" = "FreeBSD" ]; then
	OLDHOST=`hostname -f`
else
	OLDHOST=`hostname --fqdn`
fi

/bin/hostname $1

if [ "${OLDHOST}" = "" ]; then
	OLDHOST=old.host.com
	echo "old hostname was blank. Setting placeholder value ${OLDHOST}"
fi

#remove any previous hostnames.
cat /etc/hosts | grep -Fv $1 | grep -Fv $OLDHOST | grep -v '#' > /etc/hosts.tmp

#start the file over
echo "# Do not remove the following line, or various programs" > /etc/hosts
echo "# that require network functionality will fail." >> /etc/hosts

COUNT=`cat /etc/hosts.tmp | grep -c localhost`
if [ $COUNT -lt "1" ]
then
	echo -e "127.0.0.1\t\tlocalhost localhost.localdomain" >> /etc/hosts
fi

cat /etc/hosts.tmp >> /etc/hosts

SHORT_HOSTNAME=${1%%.*}
echo -e "${IP}\t\t${1} ${SHORT_HOSTNAME}" >> /etc/hosts

chmod 644 /etc/hosts

if [ -e /etc/hostname ]; then
	echo $1 > /etc/hostname
fi

if [ -x /usr/bin/hostnamectl ]; then
	/usr/bin/hostnamectl --static set-hostname ${1}
fi

if [ "${OS}" = "FreeBSD" ]; then
	/usr/bin/perl -pi -e 's/hostname=(.*)/hostname=\"${1}\"/' /etc/rc.conf
fi

if [ ! -e /etc/debian_version ] && [ "${OS}" != "FreeBSD" ] && [ -s /etc/sysconfig/network ]; then
	/usr/bin/perl -pi -e 's/HOSTNAME=(.*)/HOSTNAME=${1}/' /etc/sysconfig/network
fi

#for exim.
if [ -s /etc/virtual/domains ]; then
	perl -pi -e "s/^\Q$OLDHOST\E\$/$1/" /etc/virtual/domains

	#backup plan, in case there was no old hostname
	if grep -m1 -q "^${1}$" /etc/virtual/domains; then
		echo ${1} >> /etc/virtual/domains;
	fi
fi

#this is for exim 4 as it wants the dir for the filters

V=/etc/virtual
if [ ! -e ${V} ]; then
	/bin/mkdir -p ${V}
	/bin/chown -f mail:mail ${V}
	/bin/chmod -f 755 ${V}
fi

NEW_DIR=/etc/virtual/${1}
OLD_DIR=/etc/virtual/${OLDHOST}

if [ -d ${OLD_DIR} ] && [ ! -d ${NEW_DIR} ]; then
	mv ${OLD_DIR} ${NEW_DIR}
else
	if [ ! -d ${NEW_DIR} ]; then
		/bin/mkdir -p ${NEW_DIR}
		/bin/chown -f mail:mail ${NEW_DIR}
		/bin/chmod -f 711 ${NEW_DIR}
	fi
fi

#dovecot
LMTP=/etc/dovecot/conf/lmtp.conf
if [ -s ${LMTP} ]; then
	perl -pi -e "s/\Q$OLDHOST\E/$1/" ${LMTP}
fi

SETUP=/usr/local/directadmin/scripts/setup.txt
if [ -s ${SETUP} ] && [ -s ${DIRECTADMIN_CONF} ]; then
	perl -pi -e "s/\Q$OLDHOST\E\$/$1/" ${SETUP}
fi

if [ -x /usr/local/directadmin/custombuild/build ] && [ -s /usr/local/directadmin/custombuild/options.conf ]; then
	/usr/local/directadmin/custombuild/build set redirect_host $1
fi
if grep -m1 -q '^use_hostname_for_alias=yes$' /usr/local/directadmin/custombuild/options.conf; then
	/usr/local/directadmin/custombuild/build rewrite_confs		
else
	echo "action=rewrite&value=httpd" >> /usr/local/directadmin/data/task.queue
fi

#mysql pid file.
PIDF=/var/lib/mysql/${OLDHOST}.pid
if [ -e $PIDF ]; then
	mv $PIDF /var/lib/mysql/${1}.pid
fi

PIDF=/home/mysql/${OLDHOST}.pid
if [ -e $PIDF ]; then
    mv $PIDF /home/mysql/${1}.pid
fi

#LetsEncrypt
SAN_CONFIG=/usr/local/directadmin/conf/ca.san_config
if [ -s ${SAN_CONFIG} ]; then
	perl -pi -e "s/\Q$OLDHOST\E\$/$1/" ${SAN_CONFIG}
fi

#directadmin.conf
if [ -e ${DIRECTADMIN_CONF} ] && [ -e ${DIRECTADMIN_BIN} ]; then
	${DIRECTADMIN_BIN} set servername $1
	if grep -m1 -q "^force_hostname=${OLDHOST}$" ${DIRECTADMIN_CONF}; then
		${DIRECTADMIN_BIN} set force_hostname $1
	fi
	echo 'action=httpd&value=restart' >> /usr/local/directadmin/data/task.queue
fi


exit 0
