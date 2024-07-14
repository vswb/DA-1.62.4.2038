#!/bin/sh
OS=`uname`
DA_PATH=/usr/local/directadmin
DA_SCRIPTS=${DA_PATH}/scripts
DA_TQ=${DA_PATH}/data/task.queue
DA_SYSTEMD_SERVICE=/etc/systemd/system/directadmin.service
if [ ${OS} = "FreeBSD" ]; then
	MD5SUM=/sbin/md5
else
	MD5SUM=/usr/bin/md5sum
fi
BIN_RM=/bin/rm
if [ ! -x $BIN_RM ] && [ -x /usr/bin/rm ]; then
	BIN_RM=/usr/bin/rm
fi
if [ ! -x $BIN_RM ]; then
	BIN_RM=rm
fi

if [ -s ${DA_SYSTEMD_SERVICE} ]; then

	if [ ${OS} = "FreeBSD" ]; then
		FMD5=`$MD5SUM -q $DA_SYSTEMD_SERVICE`
	else
		FMD5=`$MD5SUM $DA_SYSTEMD_SERVICE | cut -d\  -f1`
	fi

	if [ "$FMD5" = "2ac1c3fa303710d85ba77734c578cff2" ]; then
		service directadmin stop
		sleep 1
		killall -9 directadmin 2>/dev/null
		killall -9 directadmin 2>/dev/null
		cp -f ${DA_SCRIPTS}/directadmin.service ${DA_SYSTEMD_SERVICE}
		systemctl daemon-reload
		service directadmin start
	fi
fi

#create dataskq symlink or relink if one already exists
#https://www.directadmin.com/features.php?id=2997
if [ ! -L $DA_PATH/dataskq ]; then
	${BIN_RM} -f $DA_PATH/dataskq
	ln -sf directadmin $DA_PATH/dataskq
	chown -h diradmin:diradmin $DA_PATH/dataskq
fi

#added new options to templates
#echo 'action=rewrite&value=httpd' >> $DA_TQ

echo "action=cache&value=showallusers" >> /usr/local/directadmin/data/task.queue
echo "action=cache&value=safemode" >> $DA_TQ
echo "action=convert&value=cronbackups" >> $DA_TQ
echo "action=convert&value=suspendedmysql" >> $DA_TQ
echo "action=syscheck" >> $DA_TQ

if [ ! -d /usr/local/sysbk ]; then
	cd $DA_SCRIPTS
	./sysbk.sh
fi

#https://www.directadmin.com/features.php?id=1930
echo "action=da-popb4smtp&value=restart" >> $DA_TQ

#grep -H "usertype=reseller" /usr/local/directadmin/data/users/*/user.conf | cut -d/ -f7 > /usr/local/directadmin/data/admin/reseller.list
#chown diradmin:diradmin /usr/local/directadmin/data/admin/reseller.list
#chmod 600 /usr/local/directadmin/data/admin/reseller.list

if [ "${OS}" = "FreeBSD" ]; then
	CONF=/etc/newsyslog.conf
	if [ ! -s $CONF ]; then
		perl -pi -e 's/\sN\s/\t-\t/' ${CONF}
		perl -pi -e 's/\sU\s/\t-\t/' ${CONF}

		#addLog /file user:group flag pid
		addLog()
		{
			if grep -m1 -q $1 $CONF; then
				return;
			fi
			echo -e "$1\t$2\t600\t4\t*\t@T00\t$3\t$4" >> $CONF
		}

		addLog /var/log/chrootshell.log '' -
		addLog /var/log/proftpd/auth.log '' -
		addLog /var/log/proftpd/xferlog.legacy '' -
		addLog /var/log/proftpd/access.log '' - /var/run/proftpd.pid	
		addLog /var/log/pureftp.log '' - /var/run/pure-ftpd.pid
		addLog /var/log/httpd/access_log apache:apache -
		addLog /var/log/httpd/fpexe_log apache:apache -
		addLog /var/log/httpd/suexec_log apache:apache -
		addLog /var/log/suphp.log '' -
		addLog /var/log/httpd/error_log apache:apache - /var/run/httpd.pid
		addLog /var/log/exim/paniclog mail:mail -
		addLog /var/log/exim/exim_paniclog mail:mail -
		addLog /var/log/exim/rejectlog mail:mail -
		addLog /var/log/exim/exim_rejectlog mail:mail -
		addLog /var/log/exim/processlog	mail:mail -
		addLog /var/log/exim/exim_processlog mail:mail -
		addLog /var/log/exim/mainlog mail:mail - /var/run/exim.pid
		addLog /var/log/exim/exim_mainlog mail:mail - /var/run/exim.pid
		addLog /var/log/directadmin/error.log diradmin:diradmin -
		addLog /var/log/directadmin/errortaskq.log diradmin:diradmin -
		addLog /var/log/directadmin/security.log diradmin:diradmin -
		addLog /var/log/directadmin/system.log diradmin:diradmin -
		addLog /var/log/directadmin/login.log diradmin:diradmin -
		addLog /usr/local/php53/var/log/php-fpm.log '' - "/var/run/php-fpm53.pid\t30"
		addLog /usr/local/php54/var/log/php-fpm.log '' - "/var/run/php-fpm54.pid\t30"
		addLog /usr/local/php60/var/log/php-fpm.log '' - "/var/run/php-fpm60.pid\t30"

		addLog /var/www/html/roundcube/logs/errors webapps:webapps -
		addLog /var/www/html/squirrelmail/data/squirrelmail_access_log webapps:webapps -
		addLog /var/www/html/phpMyAdmin/log/auth.log webapps:webapps -
	else
		echo "Doesn't look like you have newsyslog installed";
	fi
fi

if [ -e /etc/logrotate.d ]; then
	if [ ! -e /etc/logrotate.d/directadmin ] && [ -e $DA_SCRIPTS/directadmin.rotate ]; then
		cp $DA_SCRIPTS/directadmin.rotate /etc/logrotate.d/directadmin
	fi

	if [ -e /etc/logrotate.d/directadmin ]; then
		if ! grep -m1 -q 'login.log' /etc/logrotate.d/directadmin; then
			cp $DA_SCRIPTS/directadmin.rotate /etc/logrotate.d/directadmin
		fi
	fi
fi
echo "action=addoptions" >> $DA_TQ
rm -f /usr/local/directadmin/data/skins/*/ssi_test.html 2>/dev/null
perl -pi -e 's/trusted_users = mail:majordomo:apache$/trusted_users = mail:majordomo:apache:diradmin/' /etc/exim.conf

chmod 750 /etc/virtual/majordomo

${DA_SCRIPTS}/cron_deny.sh
${DA_SCRIPTS}/check_named_conf.sh

if [ -s /etc/proftpd.conf ]; then
	perl -pi -e "s/userlog \"%u %b\"/userlog \"%u %b %m\"/" /etc/proftpd.conf
	perl -pi -e "s/userlog \"%u %b %m\"/userlog \"%u %b %m %a\"/" /etc/proftpd.conf
	
	#dont restart proftpd if it not on.
	HAS_PUREFTPD=`${DA_PATH}/directadmin c | grep ^pureftp= | cut -d= -f2`
	if [ "${HAS_PUREFTPD}" != "1" ]; then
		echo "action=proftpd&value=restart" >> /usr/local/directadmin/data/task.queue
	fi
fi

if [ -e /usr/share/spamassassin/72_active.cf ]; then
	perl -pi -e 's#header   FH_DATE_PAST_20XX.*#header   FH_DATE_PAST_20XX      Date =~ /20[2-9][0-9]/ [if-unset: 2006]#' /usr/share/spamassassin/72_active.cf
fi

if [ -e /etc/exim.key ]; then
        chown mail:mail /etc/exim.key
        chmod 600 /etc/exim.key
fi

#1.37.1
#very important update to allow DA to listen correctly on IPv4 and IPv6
if [ "${OS}" = "FreeBSD" ]; then
	if ! grep -m1 -q 'ipv6_ipv4mapping=' /etc/rc.conf; then
		echo "ipv6_ipv4mapping=\"YES\"" >> /etc/rc.conf
	fi

	if ! grep -m1 -q 'net.inet6.ip6.v6only=' /etc/sysctl.conf; then
		echo "net.inet6.ip6.v6only=0" >> /etc/sysctl.conf
		/etc/rc.d/sysctl restart
	fi

	/sbin/sysctl net.inet6.ip6.v6only=0 >/dev/null 2>&1
fi

UKN=/etc/virtual/limit_unknown
if [ ! -e $UKN ]; then
	echo 0 > $UKN;
	chown mail:mail $UKN
	chown mail:mail /etc/virtual/limit
fi
UL=/etc/virtual/user_limit
if [ ! -s ${UL} ]; then
	echo "0" > ${UL}
	chown mail:mail ${UL}
	chmod 644 ${UL}
fi

#debian if MySQL 5.5.11+
#april 21, 2011
if [ -e /etc/debian_version ]; then
			if [ -e /usr/local/directadmin/directadmin ]; then
				COUNT=`ldd /usr/local/directadmin/directadmin | grep -c libmysqlclient.so.16`
				if [ "${COUNT}" -eq 1 ]; then
					if [ ! -e /usr/local/mysql/lib/libmysqlclient.so.16 ] && [ -e /usr/local/mysql/lib/libmysqlclient.so.18 ]; then
						echo "*** Linking libmysqlclient.so.16 to libmysqlclient.so.18";
						ln -s libmysqlclient.so.18 /usr/local/mysql/lib/libmysqlclient.so.16
						ldconfig
					fi
				fi
				COUNT=`ldd /usr/local/directadmin/directadmin | grep -c libmysqlclient.so.18`
				if [ "${COUNT}" -eq 1 ]; then
					if [ ! -e /usr/local/mysql/lib/libmysqlclient.so.18 ] && [ -e /usr/local/mysql/lib/libmysqlclient.so.16 ]; then
						echo "*** Linking libmysqlclient.so.18 to libmysqlclient.so.16";
						ln -s libmysqlclient.so.16 /usr/local/mysql/lib/libmysqlclient.so.18
						ldconfig
					fi
				fi
			fi
fi

#DA 1.43.1
#http://www.directadmin.com/features.php?id=1453
echo "action=rewrite&value=filter" >> /usr/local/directadmin/data/task.queue

#DA 1.56.2
#https://www.directadmin.com/features.php?id=2332
echo 'action=rewrite&value=cron_path' >> /usr/local/directadmin/data/task.queue

#DA 1.60.5
FS=/usr/local/directadmin/data/templates/feature_sets
rm -rf ${FS}/tickets ${FS}/view_domain

exit 0
