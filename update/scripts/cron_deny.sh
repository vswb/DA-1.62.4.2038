#!/bin/sh

OS=`uname`

if [ "$OS" = "FreeBSD" ]; then
	DENY=/var/cron/deny
else
	DENY=/etc/cron.deny
fi

deny()
{
	if [ -e $DENY ]; then
		COUNT=`grep -c -e "^$1\$" $DENY`
		if [ "$COUNT" -ne 0 ]; then
			return;
		fi
	fi

	echo $1 >> $DENY
}

if [ -e $DENY ]; then
	chmod 640 $DENY
	if [ -e /etc/debian_version ]; then
		chown root:crontab $DENY
	fi
fi

deny apache
deny webapps

exit 0;
