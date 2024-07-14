#!/bin/sh
#dkim script to create keys in /etc/virtual/domain.com
#will ensure they exist and create them if missing.
#will also dump a task.queue entry to get DA to add the newly created key to the dns.

usage()
{
        echo "Usage:";
        echo "$0 <domain> (nodns) (force)";
		echo ""
		echo "Options:"
		echo "  <domain>: Required. Name of the domain to enable dkim for."
		echo "  nodns: Optional.  Prevents adding the keys to the zone."
		echo "  force: Optional.  Force overwrite of the keys with new values."
        exit 1;
}

if [ $# -lt 1 ] || [ "$1" = "--help" ] ||[ "$1" = "-h" ]; then
	usage
fi

DOMAIN=$1
DOMAIN_OWNERS=/etc/virtual/domainowners
VD=/etc/virtual/$DOMAIN
PRIV_KEY=${VD}/dkim.private.key
PUB_KEY=${VD}/dkim.public.key

ADD_DNS=1
FORCE=0

while [ "$2" != "" ]; do
    case $2 in
        nodns)			ADD_DNS=0
						;;
        force)			FORCE=1
						;;
        -h | --help)	usage
						exit
						;;
    esac
    shift
done

OS="`uname`"
if [ "${OS}" = "FreeBSD" ]; then
        CHOWN=/usr/sbin/chown
else
	CHOWN=/bin/chown
fi

if [ ! -e $CHOWN ]; then
	echo "Cannot find chown at $CHOWN";
	exit 2;
fi

DKIM_ON=`/usr/local/directadmin/directadmin c | grep dkim= | cut -d= -f2`
if [ "$DKIM_ON" -eq 0 ]; then
	echo "DKIM is not enabled. Add dkim=1 to the directadmin.conf";
	exit 3;
fi

if [ ! -d ${VD} ]; then
	echo "Unable to find ${VD}";
	exit 2;
fi


COUNT=`grep -c ^${DOMAIN}: ${DOMAIN_OWNERS}`
if [ "${COUNT}" -gt 0 ]; then
	#lets see if they've set dkim=0 in their user.conf or domains/domain.com.conf
	#https://www.directadmin.com/features.php?id=1937
	D_USER=`grep ^${DOMAIN}: ${DOMAIN_OWNERS} | cut -d\  -f2`
	USER_CONF=/usr/local/directadmin/data/users/${D_USER}/user.conf
	if [ -s ${USER_CONF} ]; then
		COUNT=`grep -c dkim=0 ${USER_CONF}`
		if [ "${COUNT}" -gt 0 ]; then
			echo "User ${D_USER} has dkim=0 set in ${USER_CONF}. Not setting dkim."
			exit 4;
		fi

		DOMAIN_CONF=/usr/local/directadmin/data/users/${D_USER}/domains/${DOMAIN}.conf
		if [ -s ${DOMAIN_CONF} ]; then
			COUNT=`grep -c dkim=0 ${DOMAIN_CONF}`
			if [ "${COUNT}" -gt 0 ]; then
				echo "Domain ${DOMAIN} has dkim=0 set in ${DOMAIN_CONF}. Not setting dkim."
				exit 5;
			fi
		fi	
	fi
fi

if [ ! -e ${PRIV_KEY} ] || [ ! -e ${PUB_KEY} ] || [ "$FORCE" = "1" ]; then
	openssl genrsa -out ${PRIV_KEY} 2048 2>&1
	openssl rsa -in ${PRIV_KEY} -out ${PUB_KEY} -pubout -outform PEM 2>&1
	chmod 600 ${PRIV_KEY} ${PUB_KEY}
	$CHOWN mail:mail ${PRIV_KEY} ${PUB_KEY}
fi

if [ "$ADD_DNS" -eq 1 ]; then
	echo "action=rewrite&value=dkim&domain=${DOMAIN}&dns=yes" >> /usr/local/directadmin/data/task.queue
fi

exit 0;
