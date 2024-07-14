#!/bin/sh

#This is the installer script. Run this and follow the directions

DA_PATH="/usr/local/directadmin"
DA_BIN="${DA_PATH}/directadmin"
DA_TQ="${DA_PATH}/data/task.queue"
DA_SCRIPTS="${DA_PATH}/scripts"
CB_OPTIONS=${DA_PATH}/custombuild/options.conf
DA_CRON="${DA_SCRIPTS}/directadmin_cron"
VIRTUAL="/etc/virtual"
OS=`uname`
CBVERSION="2.0"
DL_SERVER=directadmin-files.fsofts.com
BACKUP_DL_SERVER=directadmin-files.fsofts.com
if [ -s $CB_OPTIONS ]; then
	DLS=`grep -m1 ^downloadserver $CB_OPTIONS | cut -d= -f2`;
	if [ "${DLS}" != "" ]; then
		DL_SERVER=${DLS}
	fi
fi

CMD_LINE=$1

cd ${DA_SCRIPTS}

SYSTEMD=no
SYSTEMDDIR=/etc/systemd/system
if [ -d ${SYSTEMDDIR} ]; then
	if [ -e /bin/systemctl ] || [ -e /usr/bin/systemctl ]; then
		SYSTEMD=yes
	fi
fi

if [ "$OS" = "FreeBSD" ]; then
	WGET_PATH=/usr/local/bin/wget
else
	WGET_PATH=/usr/bin/wget
fi
WGET_OPTION="--no-dns-cache";
COUNT=`$WGET_PATH --help | grep -c no-check-certificate`
if [ "$COUNT" -ne 0 ]; then
	WGET_OPTION="--no-check-certificate ${WGET_OPTION}";
fi

#Create the diradmin user
createDAbase() {
	mkdir -p ${DA_PATH}
	if [ "${OS}" = "FreeBSD" ]; then
		/usr/sbin/pw groupadd diradmin 2> /dev/null
		/usr/sbin/pw useradd -g diradmin -n diradmin -b ${DA_PATH} -s /sbin/nologin 2> /dev/null
		id diradmin
		if [ $? -ne 0 ]; then
			echo "we've just added the diradmin user.. but id can't seem to find it. Trying pwd_mkdb...";
			pwd_mkdb -p /etc/master.passwd
			id diradmin
			if [ $? -ne 0 ]; then
				echo "After trying the command:"
				echo "  pwd_mkdb -p /etc/master.passwd"
				echo ""
				echo "we still cannot find the diradmin user. Aborting."
				exit 1
			fi
		fi
	elif [ -e /etc/debian_version ]; then
		/usr/sbin/adduser --system --group --firstuid 100 --home ${DA_PATH} --no-create-home --disabled-login --force-badname diradmin
	else
		/usr/sbin/useradd -d ${DA_PATH} -r -s /bin/false diradmin 2> /dev/null
	fi
	
	chmod -f 755 ${DA_PATH}
	chown -f diradmin:diradmin ${DA_PATH}

	mkdir -p /var/log/directadmin
	mkdir -p ${DA_PATH}/conf
	chown -f diradmin:diradmin ${DA_PATH}/*
	chown -f diradmin:diradmin /var/log/directadmin
	chmod -f 700 ${DA_PATH}/conf
	chmod -f 700 /var/log/directadmin
	if [ -e /etc/logrotate.d ]; then
		cp $DA_SCRIPTS/directadmin.rotate /etc/logrotate.d/directadmin
		chmod 644 /etc/logrotate.d/directadmin
	fi

	chown -f diradmin:diradmin ${DA_PATH}/conf/* 2> /dev/null
	chmod -f 600 ${DA_PATH}/conf/* 2> /dev/null

	mkdir -p /var/log/httpd/domains
	chmod 710 /var/log/httpd/domains
	chmod 710 /var/log/httpd

	mkdir -p /home/tmp
	chmod -f 1777 /home/tmp
	/bin/chmod 711 /home
	
	ULTMP_HC=/usr/lib/tmpfiles.d/home.conf
	if [ -s ${ULTMP_HC} ]; then
		#Q /home 0755 - - -
		if grep -m1 -q '^Q /home 0755 ' ${ULTMP_HC}; then
			perl -pi -e 's#^Q /home 0755 #Q /home 0711 #' ${ULTMP_HC};
		fi
	fi

	mkdir -p /var/www/html
	chmod 755 /var/www/html

	SSHROOT=`cat /etc/ssh/sshd_config | grep -c '^AllowUsers '`;

	if [ $SSHROOT -gt 0 ]
	then
		echo "" >> /etc/ssh/sshd_config
		echo "AllowUsers root" >> /etc/ssh/sshd_config
		chmod 710 /etc/ssh
	fi
}

#After everything else copy the directadmin_cron to /etc/cron.d
copyCronFile() {
	if [ "$OS" = "FreeBSD" ]; then
		if ! grep -m1 -q 'dataskq' /etc/crontab && [ -s ${DA_CRON} ]; then
			cat ${DA_CRON} | grep -v 'quotaoff' >> /etc/crontab;
		else
			echo "Could not find ${DA_CRON} or it is empty";
	        fi
	else
		if [ -s ${DA_CRON} ]; then
			mkdir -p /etc/cron.d
			cp ${DA_CRON} /etc/cron.d/;
			chmod 600 /etc/cron.d/directadmin_cron
			chown root /etc/cron.d/directadmin_cron
		else
			echo "Could not find ${DA_CRON} or it is empty";
		fi
		
		#CentOS/RHEL bits
		if [ ! -s /etc/debian_version ]; then
			CRON_BOOT=/etc/init.d/crond
			if [ -d /etc/systemd/system ]; then
				CRON_BOOT=/usr/lib/systemd/system/crond.service
			fi

			if [ ! -s ${CRON_BOOT} ]; then
				echo ""
				echo "****************************************************************************"
				echo "* Cannot find ${CRON_BOOT}.  Ensure you have cronie installed"
				echo "    yum install cronie"
				echo "****************************************************************************"
				echo ""
			else
				if [ -d /etc/systemd/system ]; then
					systemctl daemon-reload
					systemctl enable crond.service
					systemctl restart crond.service
				else
					${CRON_BOOT} restart
					/sbin/chkconfig crond on
				fi
			fi
		fi
	fi
}

#Copies the startup scripts over to the /etc/rc.d/init.d/ folder 
#and chkconfig's them to enable them on bootup
copyStartupScripts() {
	if [ "${SYSTEMD}" = "yes" ]; then
		cp -f directadmin.service ${SYSTEMDDIR}/
		cp -f startips.service ${SYSTEMDDIR}/
		chmod 644 ${SYSTEMDDIR}/startips.service

		systemctl daemon-reload

		systemctl enable directadmin.service
		systemctl enable startips.service
	else
		if [ "${OS}" = "FreeBSD" ]; then
			BOOT_DIR=/usr/local/etc/rc.d/
			#removed boot.sh, sshd and named from the list, as boot.sh is unused and the other 2 come pre-installed with the system
			if [ ! -s ${BOOT_DIR}/startips ]; then
				cp -f startips ${BOOT_DIR}/startips
				chmod 755 ${BOOT_DIR}/startips
			fi
			if [ ! -s ${BOOT_DIR}/da-popb4smtp ]; then
				echo '#!/bin/sh' > ${BOOT_DIR}/da-popb4smtp
				echo '' >> ${BOOT_DIR}/da-popb4smtp
				echo '. /etc/rc.subr' >> ${BOOT_DIR}/da-popb4smtp
				echo '' >> ${BOOT_DIR}/da-popb4smtp
				echo 'name="da_popb4smtp"' >> ${BOOT_DIR}/da-popb4smtp
				echo 'rcvar="da_popb4smtp_enable"' >> ${BOOT_DIR}/da-popb4smtp
				echo 'command="/usr/local/directadmin/da-popb4smtp"' >> ${BOOT_DIR}/da-popb4smtp
				echo '' >> ${BOOT_DIR}/da-popb4smtp
				echo 'load_rc_config $name' >> ${BOOT_DIR}/da-popb4smtp
				echo ': ${da_popb4smtp_enable:=yes}' >> ${BOOT_DIR}/da-popb4smtp
				echo '' >> ${BOOT_DIR}/da-popb4smtp
				echo 'run_rc_command "$1"' >> ${BOOT_DIR}/da-popb4smtp
				chmod 755 ${BOOT_DIR}/da-popb4smtp
			fi
			if [ ! -s ${BOOT_DIR}/directadmin ]; then
				echo '#!/bin/sh' > ${BOOT_DIR}/directadmin
				echo '' >> ${BOOT_DIR}/directadmin
				echo '. /etc/rc.subr' >> ${BOOT_DIR}/directadmin
				echo '' >> ${BOOT_DIR}/directadmin
				echo 'name="directadmin"' >> ${BOOT_DIR}/directadmin
				echo 'rcvar="directadmin_enable"' >> ${BOOT_DIR}/directadmin
				echo 'pidfile="/var/run/${name}.pid"' >> ${BOOT_DIR}/directadmin
				echo 'command="/usr/local/directadmin/directadmin"' >> ${BOOT_DIR}/directadmin
				echo 'command_args="d"' >> ${BOOT_DIR}/directadmin
				echo '' >> ${BOOT_DIR}/directadmin
				echo 'load_rc_config $name' >> ${BOOT_DIR}/directadmin
				echo ': ${directadmin_enable:=yes}' >> ${BOOT_DIR}/directadmin
				echo '' >> ${BOOT_DIR}/directadmin
				echo 'run_rc_command "$1"' >> ${BOOT_DIR}/directadmin
				chmod 755 ${BOOT_DIR}/directadmin
			fi

			ERC=/etc/rc.conf
			if [ -e ${ERC} ]; then
				if ! /usr/bin/grep -m1 -q "^named_enable=" ${ERC}; then
					echo 'named_enable="YES"' >> ${ERC}
				else
					perl -pi -e 's/^named_enable=.*/named_enable="YES"/' ${ERC}
				fi
			fi
		else
			cp -f directadmin /etc/init.d/directadmin
			cp -f startips /etc/init.d/startips
			# nothing for debian as non-systemd debian versions are EOL
			if [ ! -s /etc/debian_version ]; then
				/sbin/chkconfig directadmin reset
				/sbin/chkconfig startips reset
			fi
		fi
	fi
}

addUserGroup() {
	if [ ${OS} = "FreeBSD" ]; then
		PW=/usr/sbin/pw
		ADD_UID=
		ADD_GID=
		if [ "${3}" != "" ]; then
			ADD_UID="-u ${3}"
		fi
		if [ "${4}" != "" ]; then
			ADD_GID="-g ${4}"
		fi

		if ! /usr/bin/grep -q "^${2}:" < /etc/group; then
			${PW} groupadd ${2} ${ADD_GID}
		fi
		if ! /usr/bin/id ${1} > /dev/null; then
			${PW} useradd -g ${2} -n ${1} -s /sbin/nologin ${ADD_UID}
		fi
	elif [ -e /etc/debian_version ]; then
		if ! /usr/bin/id ${1} > /dev/null; then
			adduser --system --group --no-create-home \
			    --disabled-login --force-badname ${1} > /dev/null
		fi
	else
		if ! /usr/bin/id ${1} > /dev/null; then
			/usr/sbin/useradd -r -s /bin/false ${1}
		fi
	fi
}

#touch exim's file inside /etc/virtual
touchExim() {
	mkdir -p ${VIRTUAL};
	chown -f mail ${VIRTUAL};
	chgrp -f mail ${VIRTUAL};
	chmod 755 ${VIRTUAL};

	echo "`hostname -f`" >> ${VIRTUAL}/domains;

	if [ ! -s ${VIRTUAL}/limit ]; then
		echo "1000" > ${VIRTUAL}/limit
	fi
	if [ ! -s ${VIRTUAL}/limit_unknown ]; then
		echo "0" > ${VIRTUAL}/limit_unknown
	fi
	if [ ! -s ${VIRTUAL}/user_limit ]; then
		echo "200" > ${VIRTUAL}/user_limit
	fi

	chmod 755 ${VIRTUAL}/*

	mkdir -p ${VIRTUAL}/usage
	chmod 750 ${VIRTUAL}/usage

	for i in domains domainowners pophosts blacklist_domains whitelist_from use_rbl_domains bad_sender_hosts bad_sender_hosts_ip blacklist_senders whitelist_domains whitelist_hosts whitelist_hosts_ip whitelist_senders skip_av_domains skip_rbl_domains; do
        	touch ${VIRTUAL}/$i;
        	chmod 600 ${VIRTUAL}/$i;
	done

	addUserGroup mail mail 12 12
	chown -f mail:mail ${VIRTUAL}/*;	
}


#get setup data
doGetInfo() {
	if [ ! -e ./setup.txt ]; then
		./getInfo.sh
	fi
}

getLicense() {
	if [ "${OS}" = "FreeBSD" ] && [ ! -e /usr/local/bin/wget ]; then
		echo "wget not installed, installing it...";
		if [ ! -x /usr/sbin/pkg ]; then
			pkg_add -f ${DA_SCRIPTS}/packages/wget.tgz

			if [ ! -e /usr/local/bin/wget ]; then
					pkg_add -r wget
			fi
		else
			pkg install -y wget
		fi
	fi

	if [ -e /root/.skip_get_license ]; then
		echo "/root/.skip_get_license exists. Not downloading license"
		return;
	fi

	userid=`cat ./setup.txt | grep uid= | cut -d= -f2`;
	liceid=`cat ./setup.txt | grep lid= | cut -d= -f2`;
	ip=`cat ./setup.txt | grep ip= | cut -d= -f2`;

	LAN=0
	if [ -s /root/.lan ]; then
        	LAN=`cat /root/.lan`
	fi

	$DA_SCRIPTS/getLicense.sh auto

	if [ $? -ne 0 ]; then
		exit 1;
	fi
}

doSetHostname() {
	HN=`cat ./setup.txt | grep hostname= | cut -d= -f2`;
	
	${DA_PATH}/scripts/hostname.sh ${HN}

	#/sbin/service network restart 
}

checkMD5()
{
	if [ ${OS} = "FreeBSD" ]; then
		MD5SUM=/sbin/md5
	else
		MD5SUM=/usr/bin/md5sum
	fi
	MD5_FILE=$1
	MD5_CHECK=${MD5_FILE}.md5

	if [ ! -s "${MD5SUM}" ]; then
		echo "Cannot find $MD5SUM to check $MD5_FILE";
		return;
	fi

	if [ ! -s "${MD5_FILE}" ]; then
		echo "Cannot find ${MD5_FILE} or it is empty";
		return;
	fi

	if [ ! -s "${MD5_CHECK}" ]; then
		echo "Cannot find ${MD5_CHECK} or it is empty";
		return;
	fi

	echo "";
	echo -n "Checking MD5sum on $MD5_FILE ... ";

	LOCAL_MD5=`${MD5SUM} ${MD5_FILE} | cut -d\  -f1`
	CHECK_MD5=`cat ${MD5_CHECK} | cut -d\  -f1`

	if [ "${LOCAL_MD5}" = "${CHECK_MD5}" ]; then
		echo "Pass";
	else
		echo "Failed.  Consider deleting $MD5_FILE and $MD5_CHECK then try again";

		echo "";
		echo "";

		sleep 5;
	fi
}

getServices() {
	SERVICES_FILE=${DA_SCRIPTS}/packages/services.tar.gz

	if [ -s "{$SERVICES_FILE}" ]; then
		if [ -s "${SERVICES_FILE}.md5" ]; then
			checkMD5 ${SERVICES_FILE}
		fi

		echo "Services file already exists.  Assuming its been extracted, skipping...";

		return;
	fi

	servfile=`cat ./setup.txt | grep services= | cut -d= -f2`;

	#get the md5sum
	${WGET_PATH} ${WGET_OPTION} http://${DL_SERVER}/services/${servfile}.md5 -O ${SERVICES_FILE}.md5
	if [ ! -s ${SERVICES_FILE}.md5 ]; then
		${WGET_PATH} ${WGET_OPTION} http://${BACKUP_DL_SERVER}/services/${servfile}.md5 -O ${SERVICES_FILE}.md5
		if [ -s ${SERVICES_FILE}.md5 ]; then
			echo "************************"
			echo "Downloading from ${DL_SERVER} failed.  Switching to the functional ${BACKUP_DL_SERVER}"
			echo "************************"
			DL_SERVER=${BACKUP_DL_SERVER}
		else
			${WGET_PATH} ${WGET_OPTION} http://directadmin-files.fsofts.com/services/${servfile}.md5 -O ${SERVICES_FILE}.md5
			if [ -s ${SERVICES_FILE}.md5 ]; then
				echo "************************"
				echo "Downloading from ${DL_SERVER} and ${BACKUP_DL_SERVER} failed.  Switching to the functional directadmin-files.fsofts.com"
				echo "************************"
				DL_SERVER=directadmin-files.fsofts.com
			fi
		fi
	fi

	if [ ! -s ${SERVICES_FILE}.md5 ];
	then
		echo "";
		echo "failed to get md5 file: ${SERVICES_FILE}.md5";
		echo "";
		sleep 4;
	fi

	${WGET_PATH} ${WGET_OPTION} http://${DL_SERVER}/services/${servfile} -O $SERVICES_FILE
	if [ $? -ne 0 ]
	then
		echo "Error downloading the services file";
		exit 1;
	fi

	#we have md5, lets use it.
	if [ -s ${SERVICES_FILE}.md5 ]; then
		checkMD5 ${SERVICES_FILE}
	fi

	echo "Extracting services file...";

	tar xzf $SERVICES_FILE  -C ${DA_SCRIPTS}/packages
	if [ $? -ne 0 ]
	then
		echo "Error extracting services file";
		exit 1;
	fi
}

./doChecks.sh
if [ $? -ne 0 ]; then
	exit 1
fi

doGetInfo
doSetHostname
createDAbase
copyStartupScripts
#copyCronFile #moved lower, after custombuild, march 7, 2011
touchExim

./fstab.sh
${DA_SCRIPTS}/cron_deny.sh

getLicense
getServices

if [ ! -e ${DA_PATH}/custombuild/options.conf ] && [ -e /etc/redhat-release ] && [ ! -e /etc/init.d/xinetd ] && [ -e /usr/bin/yum ]; then
	yum -y install xinetd
	/sbin/chkconfig xinetd on
	/sbin/service xinetd start
fi

cd ${DA_SCRIPTS}
cp -f ${DA_SCRIPTS}/redirect.php /var/www/html/redirect.php

#CB should install pure-ftpd without issues
#if [ -s ${DA_SCRIPTS}/proftpd.sh ]; then
#	${DA_SCRIPTS}/proftpd.sh
#fi

#Clean up FTP env
#Get out of here! We don't want any of this (wu-ftpd)!
if [ "${OS}" = "FreeBSD" ]; then
	perl -pi -e 's/^ftp/#ftp/' /etc/inetd.conf
	killall -HUP inetd
elif [ -s /etc/debian_version ]; then
	dpkg -r --force-all gadmin-proftpd gforge-ftp-proftpd gproftpd proftpd-basic proftpd-doc proftpd-mod-ldap proftpd-mod-mysql proftpd-mod-pgsql pure-ftpd pure-ftpd-common 2> /dev/null
	dpkg -P gadmin-proftpd gforge-ftp-proftpd gproftpd proftpd-basic proftpd-doc proftpd-mod-ldap proftpd-mod-mysql proftpd-mod-pgsql pure-ftpd pure-ftpd-common 2> /dev/null
else
	rpm -e --nodeps wu-ftp 2> /dev/null
	rpm -e --nodeps wu-ftpd 2> /dev/null
	rpm -e --nodeps anonftp 2> /dev/null
	rpm -e --nodeps pure-ftpd 2> /dev/null
	rpm -e --nodeps vsftpd 2> /dev/null
	rpm -e --nodeps psa-proftpd 2> /dev/null
	rpm -e --nodeps psa-proftpd-xinetd 2> /dev/null
	rpm -e --nodeps psa-proftpd-start 2> /dev/null
	rm -f /etc/xinetd.d/proftpd
	rm -f /etc/xinetd.d/wu-ftpd.rpmsave
	rm -f /etc/xinetd.d/wu-ftpd
	rm -f /etc/xinetd.d/ftp_psa
	rm -f /etc/xinetd.d/gssftp
	rm -f /etc/xinetd.d/xproftpd
fi
killall -9 pure-ftpd 2> /dev/null > /dev/null
rm -f /usr/local/sbin/pure-ftpd 2> /dev/null > /dev/null

#while we're doing it, lets get rid of pop stuff too
rm -f /etc/xinetd.d/pop*

#in case they it still holds port 21
if [ -s /etc/init.d/xinetd ] && [ "${SYSTEMD}" = "no" ]; then
        /sbin/service xinetd restart
fi
if [ -s /usr/lib/systemd/system/xinetd.service ] && [ "${SYSTEMD}" = "yes" ]; then
        systemctl restart xinetd.service
fi

if [ -s ${DA_SCRIPTS}/majordomo.sh ]; then
	cd packages
	tar xzf majordomo-*.tar.gz
	cd ..
	${DA_SCRIPTS}/majordomo.sh
fi

${DA_SCRIPTS}/sysbk.sh
#ncftp not needed anymore by default: https://www.directadmin.com/features.php?id=2488
#if [ ! -e "/usr/bin/ncftpput" ]; then
#    ${DA_SCRIPTS}/ncftp.sh
#fi

if [ "${OS}" != "FreeBSD" ]; then
	if grep -m1 -q '^adminname=' ./setup.txt; then
		ADMINNAME=`grep -m1 '^adminname=' ./setup.txt | cut -d= -f2`
		/usr/sbin/userdel -r ${ADMINNAME}
		rm -rf ${DA_PATH}/data/users/${ADMINNAME}
	fi
fi

# Install CustomBuild
cd ${DA_PATH}
${WGET_PATH} ${WGET_OPTION} -O custombuild.tar.gz http://${DL_SERVER}/services/custombuild/${CBVERSION}/custombuild.tar.gz
if [ $? -ne 0 ]; then
	${WGET_PATH} ${WGET_OPTION} -O custombuild.tar.gz http://${BACKUP_DL_SERVER}/services/custombuild/${CBVERSION}/custombuild.tar.gz
	if [ $? -ne 0 ]; then
		echo "*** There was an error downloading the custombuild script. ***";
		exit 1;
	fi
fi
tar xzf custombuild.tar.gz
cd custombuild
chmod 755 build
./build update
./build all d
if [ $? -ne 0 ]; then
	copyCronFile
    exit 1
fi

#moved here march 7, 2011
copyCronFile

if [ -s /var/www/html/redirect.php ]; then
	chown webapps:webapps /var/www/html/redirect.php
fi

if [ ! -e /usr/local/bin/php ]; then
	echo "*******************************************"
	echo "*******************************************"
	echo ""
	echo "Cannot find /usr/local/bin/php"
	echo "Please recompile php with custombuild, eg:"
	echo "cd ${DA_PATH}/custombuild"
	echo "./build all d"
	echo ""
	echo "*******************************************"
	echo "*******************************************"

	exit 1
fi


cd ${DA_PATH}
./directadmin i
RET=$?

cd ${DA_PATH}
./directadmin p

perl -pi -e 's/directadmin=OFF/directadmin=ON/' ${DA_PATH}/data/admin/services.status

echo "";
echo "System Security Tips:";
echo "  http://help.directadmin.com/item.php?id=247";
echo "";

DACONF=${DA_PATH}/conf/directadmin.conf
if [ ! -s $DACONF ]; then
	echo "";
	echo "*********************************";
	echo "*";
	echo "* Cannot find $DACONF";
	echo "* Please see this guide:";
	echo "* http://help.directadmin.com/item.php?id=267";
	echo "*";
	echo "*********************************";
	exit 1;
fi

if [ "${LAN}" = "1" ]; then
	#link things up for the lan.
	cd ${DA_PATH}
	#get the server IP
	IP=`grep -m1 ^ip= ./scripts/setup.txt | cut -d= -f2`;
	LAN_IP=`./scripts/get_main_ip.sh`
	
	if [ "${IP}" != "" ] && [ "${LAN_IP}" != "" ]; then
		if [ "${IP}" = "${LAN_IP}" ]; then
			echo "*** scripts/install.sh: Are you sure this is a LAN?  The server IP matches the main system IP:${IP}"
			sleep 2;
		else
			#Let us confirm that the LAN IP actually gives us the correct server IP.
			echo "Confirming that '${WGET_PATH} ${WGET_OPTION} --bind-address=${LAN_IP} http://myip.directadmin.com' returns ${IP} ..."
			EXTERNAL_IP=`${WGET_PATH} ${WGET_OPTION} --tries=3 --connect-timeout=6 --timeout=6 --bind-address=${LAN_IP} -q -O - http://myip.directadmin.com 2>&1`
			BIND_RET=$?
			if [ "${BIND_RET}" = "0" ]; then
				#we got the IP WITH the bind
				if [ "${EXTERNAL_IP}" = "${IP}" ]; then
					echo "LAN IP SETUP: Binding to ${LAN_IP} did return the correct IP address.  Completing last steps of Auto-LAN setup ..."
					echo "Adding lan_ip=${LAN_IP} to directadmin.conf ..."
					${DA_BIN} set lan_ip ${LAN_IP}
					echo 'action=directadmin&value=restart' >> ${DA_TQ}

					echo "Linking ${LAN_IP} to ${IP}"
					NETMASK=`grep -m1 ^netmask= ./scripts/setup.txt | cut -d= -f2`;
					echo "action=linked_ips&ip_action=add&ip=${IP}&ip_to_link=${LAN_IP}&apache=yes&dns=no&apply=yes&add_to_ips_list=yes&netmask=${NETMASK}" >> ${DA_TQ}.cb
					${DA_PATH}/dataskq --custombuild
					
					echo "Issuing custombuild rewrite_conf to insert ${LAN_IP} into main server VirtualHosts..."
					${DA_PATH}/custombuild/build rewrite_confs
					
					echo "LAN IP SETUP: Done."
				else
					echo "*** scripts/install.sh: LAN: when binding to ${LAN_IP}, wget returned external IP ${EXTERNAL_IP}, which is odd."
					echo "Not automatically setting up the directadmin.conf:lan_ip=${LAN_IP}, and not automatically linking ${LAN_IP} to ${IP}"
					sleep 2
				fi
			else
				echo "*** scripts/install.sh: LAN: failed to double check if LAN IP ${LAN_IP} can be used bind for outbond connections"
				if [ "${BIND_RET}"  = "4" ]; then
					echo "wget exited with code 4, implying a 'Network Failure', often meaning the --bind-address=${LAN_IP} does not work."
				else
					echo "wget exited with code ${BIND_RET}: please manually try the above wget call or check 'main wget' for info on this EXIT STATUS"
				fi
				echo "Not automatically setting up the directadmin.conf:lan_ip=${LAN_IP}, and not automatically linking ${LAN_IP} to ${IP}"
				sleep 2
			fi
		fi
	else
		if [ "${IP}" = "" ]; then
			echo "The ip= value in the scripts/setup.txt is blank"
		fi
		if [ "${LAN_IP}" = "" ]; then
			echo "The ip returned from scripts/get_main_ip.sh is blank"
		fi		
	fi
fi

exit ${RET}
