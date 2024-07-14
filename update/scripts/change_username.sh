#!/bin/sh
#VERSION=2.3
#
# Script used to change the name of a user
#
# Usage: change_username.sh

VERBOSE=1

MAX_LENGTH=10
SYSTEM_USER_TO_VIRTUAL_PASSWD=0
DA_BIN=/usr/local/directadmin/directadmin
DATASKQ_BIN=/usr/local/directadmin/dataskq
TASKQ=/usr/local/directadmin/data/task.queue
TASKQ_CB=${TASKQ}.cb
DA_DATA_USERS=/usr/local/directadmin/data/users
PURE_PW=/usr/bin/pure-pw
if [ -s "$DA_BIN" ]; then
	VAL=`${DA_BIN} c |grep '^max_username_length=' | cut -d= -f2`
	if [ "$VAL" != "" ]; then
		if [ "$VAL" -gt 0 ]; then
			MAX_LENGTH=$VAL
		fi
	fi
	VAL=`${DA_BIN} c |grep '^system_user_to_virtual_passwd=' | cut -d= -f2`
	if [ "$VAL" != "" ]; then
		if [ "$VAL" -gt 0 ]; then
			SYSTEM_USER_TO_VIRTUAL_PASSWD=$VAL
		fi
	fi
	
	if [ -s /etc/pureftpd.pdb ]; then
		VAL=`${DA_BIN} c |grep '^pure_pw=' | cut -d= -f2`
		if [ "$VAL" != "" ]; then
			PURE_PW=$VAL
		fi
	fi
fi

show_help()
{
	echo "DirectAdmin username changing script (Beta)";
	echo "";
	echo "Usage: $0 oldusername newusername";
	echo "";
}

if [ $# -lt 2 ]; then
	show_help
	exit 0
fi

SYSTEMD=no
SYSTEMDDIR=/etc/systemd/system
if [ -d ${SYSTEMDDIR} ] && [ -e /usr/bin/systemctl ]; then
	SYSTEMD=yes
fi

OS=`uname`;

OHOME=`grep -e "^${1}:" /etc/passwd | cut -d: -f6`
HOME_PATH=`dirname $OHOME`
NHOME=

str_len()
{
	echo ${#1}
}

ensure_user()
{
	/usr/bin/id $1 1>/dev/null 2>/dev/null
	if [ $? != 0 ]; then
		echo "Cannot find user $1";
		exit 2;
	fi
}

prevent_user()
{
    /usr/bin/id $1 1>/dev/null 2>/dev/null
    if [ $? = 0 ]; then
            echo "User $1 already exists";
            exit 4;
    fi

	if ! echo "$1" | grep -m1 -q '^[0-9a-z]*$'; then
		echo "Username $1 is invalid";
		exit 8;
	fi

	LEN=`str_len $1`
	if [ "$LEN" != "" ]; then
		if [ "$LEN" -gt "$MAX_LENGTH" ]; then
			echo "User $1 is $LEN characters long.";
			echo "The current max is:";
			echo "max_username_length=$MAX_LENGTH";
			exit 5;
		fi
	fi
}

#rename cron files and spool files else they'll be removed
#when account is removed.
#redhat does /var/spool/mail/user for us
move_spool_cron()
{
	if [ "$OS" = "FreeBSD" ]; then
		mv -f /var/mail/$1 /var/mail/$2 2>/dev/null
		mv -f /var/cron/tabs/$1 /var/cron/tabs/$2 2>/dev/null
	else
		mv -f /var/spool/cron/$1 /var/spool/cron/$2 2>/dev/null
	fi
}

rename_cron_user()
{
	CRONTAB=/var/spool/cron/$1
	if [ "$OS" = "FreeBSD" ]; then
		CRONTAB=/var/cron/tabs/$1
	fi

	if [ -s $CRONTAB ]; then
		#swap the actual cron data.
		TEMP="/usr/bin/perl -pi -e 's#([\s:])${OHOME}/#\$1${NHOME}/#g' ${CRONTAB}"
		eval $TEMP;
	fi

	move_spool_cron $1 $2
	
	#da_swap has not yet been called. Use old user/crontab.conf
	CRONTAB=${DA_DATA_USERS}/$1/crontab.conf
	if [ -s ${CRONTAB} ]; then
		#swap the actual cron data.
		TEMP="/usr/bin/perl -pi -e 's#([\s:])${OHOME}/#\$1${NHOME}/#g' ${CRONTAB}"
		eval $TEMP;	
	fi
}

system_swap()
{
	echo "Killing User processes:"
	/usr/bin/killall -s SIGKILL -u "$1"
	
	if [ "$OS" = "FreeBSD" ]; then
		#have to add a new user to the same id, then remove the other user
		OUID=`grep -e "^${1}:" /etc/passwd | cut -d: -f3`
		OGID=`grep -e "^${1}:" /etc/passwd | cut -d: -f4`
		OPASS=`grep -e "^${1}:" /etc/master.passwd | cut -d: -f2`
		OSHELL=`grep -e "^${1}:" /etc/passwd | cut -d: -f7`
		
		#some FreeBSD's don't support -H
		#echo $OPASS | /usr/sbin/pw useradd -n $2 -s $OSHELL -o -w no -u $OUID -g $OGID -H 0

		/usr/sbin/pw useradd -n $2 -s $OSHELL -o -w no -u $OUID -g $OGID
		chpass -p $OPASS $2

		#now do the group
		pw groupmod $1 -l $2 -q

	else
		/usr/sbin/usermod -l $2 -d $HOME_PATH/$2 $1

		#now do the group
		/usr/sbin/groupmod -n $2 $1
	fi

	ensure_user $2

	NHOME=`grep -e "^${2}:" /etc/passwd | cut -d: -f6`

	rename_cron_user $1 $2

	if [ "$OS" = "FreeBSD" ]; then
		pw userdel $1
	fi

	mv -f $OHOME $NHOME

	#update sshd_config if user exists:
	TEMP="/usr/bin/perl -pi -e 's/AllowUsers ${1}\$/AllowUsers ${2}/' /etc/ssh/sshd_config"
	eval $TEMP;
}

security_check()
{
	if [ "$1" = "root" ]; then
		echo "Are you mad? we don't play with root here. He's not nice.";
		exit 5;
	fi

	for i in all action value domain email type root mail jail creator diradmin majordomo start stop reload restart demo_user demo_reseller demo_admin demo type backup log www apache mysql tmp test; do
	{
		if [ "$1" = "$i" ]; then
			echo "$1 is a reserved username, please choose another";
			exit 5;
		fi
	};
	done;

	if [ "$1" = "" ]; then
		echo "blank user..make sure you've passed 2 usernames";
		exit 6;
	fi
	
	if [ ! -e /usr/bin/perl ]; then
		echo "/usr/bin/perl does not exist";
		exit 7;
	fi
}

generic_swap()
{
	TEMP="/usr/bin/perl -pi -e 's/(^|[\s=\/:])${1}([\s\/:]|\$)/\${1}${2}\${2}/g' $3"
	eval $TEMP;
}

mailing_list_swap()
{
	TEMP="/usr/bin/perl -pi -e 's/([\s:])${1}([\s@]|\$)/\${1}${2}\${2}/g' $3"
	eval $TEMP;
}

ftp_pass_swap()
{
	TEMP="/usr/bin/perl -pi -e 's/(^)${1}([:])/\${1}${2}\${2}/g' $3"
	eval $TEMP;

	TEMP="/usr/bin/perl -pi -e 's#${OHOME}([:\/])#${NHOME}\${1}#g' $3"
	eval $TEMP;
}

awstats_swap()
{
	#its called after system_swap, so we do it on user $2.
	TEMP="/usr/bin/perl -pi -e 's#${OHOME}/#${NHOME}/#g' ${NHOME}/domains/*/awstats/.data/*.conf"
    eval $TEMP;

	TEMP="/usr/bin/perl -pi -e 's#${OHOME}/#${NHOME}/#g' ${NHOME}/domains/*/awstats/awstats.pl"
	eval $TEMP;
}
installatron_swap()
{
	if [ -d ${NHOME}/.appdata/current ]; then
		TEMP="/usr/bin/perl -pi -e 's/${1}/${2}/' ${NHOME}/.appdata/current/*"
		eval $TEMP;
	fi
	if [ -d ${NHOME}/.appdata/backups ]; then
		TEMP="/usr/bin/perl -pi -e 's/${1}/${2}/' ${NHOME}/.appdata/backups/*"
		eval $TEMP;
	fi
}

snidomains_swap()
{
	SNIDOMAINS=/etc/virtual/snidomains
	if [ ! -s ${SNIDOMAINS} ]; then
		return
	fi
	TEMP="/usr/bin/perl -pi -e 's/:${1}:/:${2}:/' ${SNIDOMAINS}"
	eval $TEMP;
}

email_swap()
{
	#/etc/virtual/domainowners
	#/etc/virtual/

	DATA_USER_OLD=${DA_DATA_USERS}/${1}/
	DATA_USER_NEW=${DA_DATA_USERS}/${2}/
	
	generic_swap $1 $2 /etc/virtual/domainowners
	snidomains_swap $1 $2

	DEFAULT_DOMAIN_NAME=`readlink ${NHOME}/public_html | grep -m1 -o '/[^/]*\.[^/]*/' | cut -d/ -f2`
	
	DEFAULT_DOMAIN=false
	
    if [ -L "${NHOME}/Maildir" ]; then
        OLD_SYMLINK_TARGET=`readlink "${NHOME}/Maildir"`
        NEW_SYMLINK_TARGET=`echo "${OLD_SYMLINK_TARGET}" | perl -p0 -e "s|/$1/|/$2/|g"`
        if [ -d ${NEW_SYMLINK_TARGET} ]; then
            ln -sf "${NEW_SYMLINK_TARGET}" "${NHOME}/Maildir"
        fi
    fi

	for i in `cat ${DA_DATA_USERS}/$1/domains.list`; do
	{
		if [ ! -z "${DEFAULT_DOMAIN}" ] && [ "${i}" = "${DEFAULT_DOMAIN_NAME}" ]; then
			DEFAULT_DOMAIN=true
			DEFAULT_MAIL_MOVED=false
		fi

		#check for suspended domains
		if [ ! -e /etc/virtual/$i ]; then
			if [ -e /etc/virtual/${i}_off ]; then
				i=${i}_off
			fi
		fi

		if [ "${SYSTEM_USER_TO_VIRTUAL_PASSWD}" = "1" ] && [ -e "${NHOME}/Maildir" ] && ${DEFAULT_DOMAIN}; then
			MAIL_LOCATION=`grep "^$1:" /etc/virtual/$i/passwd | cut -d: -f6 | perl -p0 -e "s|$1$|$2|g"`

			if [ -z "${MAIL_LOCATION}" ] || [ ! -d "${MAIL_LOCATION}" ]; then
				MAIL_FOLDER=`/usr/local/directadmin/directadmin c | grep '^mail_partition=' | cut -d= -f2`
                MAIL_LOCATION=${NHOME}
                if [ -z "${MAIL_FOLDER}" ]; then
                    MAIL_FOLDER=${NHOME}/imap/${i}/${1}
                else
                    MAIL_LOCATION=${MAIL_FOLDER}
                    MAIL_FOLDER=${MAIL_FOLDER}/imap/${i}/${1}
                fi
			else
				MAIL_FOLDER=${MAIL_LOCATION}/imap/${i}/${1}
			fi
			if [ ! -d ${MAIL_FOLDER}/Maildir ] && [ -d ${MAIL_LOCATION}/Maildir ]; then
				mkdir -p ${MAIL_FOLDER}
				chown $2:mail ${MAIL_FOLDER}
				mv ${MAIL_LOCATION}/Maildir ${MAIL_FOLDER}
				#used for system account, if it had such account name - move it back to system account
				REALPATH_SYSTEM_FOLDER=`realpath ${MAIL_FOLDER}/../${2}`
				if [ -z "${REALPATH_SYSTEM_FOLDER}" ]; then
					REALPATH_SYSTEM_FOLDER=`readlink -e ${MAIL_FOLDER}/../${2}`
				fi
                if [ ! -z "${REALPATH_SYSTEM_FOLDER}" ] && [ -d "${REALPATH_SYSTEM_FOLDER}" ]; then
                    mv ${REALPATH_SYSTEM_FOLDER} ${MAIL_LOCATION}/Maildir
					#find and remove that line with mail system account and old path
					OLDREALPATH_SYSTEM_FOLDER_BEGINNING=`echo "${REALPATH_SYSTEM_FOLDER}" | grep -m1 -o ".*$2/"`
					OLDREALPATH_SYSTEM_FOLDER_NEWBEGINNING=`echo "${OLDREALPATH_SYSTEM_FOLDER_BEGINNING}" | perl -p0 -e "s|/$2/|/$1/|g"`
					OLDREALPATH_SYSTEM_FOLDER=`echo "${REALPATH_SYSTEM_FOLDER}" | perl -p0 -e "s|^${OLDREALPATH_SYSTEM_FOLDER_BEGINNING}|${OLDREALPATH_SYSTEM_FOLDER_NEWBEGINNING}|g"`
                    sed -i "\|:${OLDREALPATH_SYSTEM_FOLDER}:|d" /etc/virtual/$i/passwd
                else
                    mkdir -p ${MAIL_LOCATION}/Maildir
                    chown $2:mail ${MAIL_LOCATION}/Maildir
                fi
				DEFAULT_MAIL_MOVED=true
			fi
		fi
	
		generic_swap $1 $2 /etc/virtual/$i/aliases
		#twice for user:user
		generic_swap $1 $2 /etc/virtual/$i/aliases
		#add aliases for the old main username
		ADD_MAIN_ACCOUNT_FORWARDER=true
		if ${DEFAULT_DOMAIN} && ${DEFAULT_MAIL_MOVED}; then
			ADD_MAIN_ACCOUNT_FORWARDER=false
		fi
		if ! grep -m1 -q "^$1:" /etc/virtual/$i/aliases; then
			if ${ADD_MAIN_ACCOUNT_FORWARDER}; then
                if ! grep -m1 -q "^$1:" /etc/virtual/$i/aliases; then
				    echo "$1:$2" >> /etc/virtual/$i/aliases
                fi
			fi
		fi
		generic_swap $1 $2 /etc/virtual/$i/autoresponder.conf
		generic_swap $1 $2 /etc/virtual/$i/filter
		generic_swap $1 $2 /etc/virtual/$i/vacation.conf

		#the dovecot passwd file uses the same format as the ftp.passwd file.
		ftp_pass_swap $1 $2 /etc/virtual/$i/passwd
		
        perl -pi -e "s|/[^/]*$1/imap/|/$2/imap/|g" /etc/virtual/$i/passwd
		if [ "${SYSTEM_USER_TO_VIRTUAL_PASSWD}" = "1" ]; then
            perl -pi -e "s/^$1:/$2:/g" /etc/virtual/$i/passwd
            OLD_MAILDIR_PATH=`grep -m1 "^$2:" /etc/virtual/$i/passwd | cut -d: -f6`
            if [ ! -z "${OLD_MAILDIR_PATH}" ]; then
                NEW_MAILDIR_PATH=`echo "${OLD_MAILDIR_PATH}" | perl -p0 -e "s|/[^/]*$1$|/$2|g"`
                perl -pi -e "s|:${OLD_MAILDIR_PATH}:|:${NEW_MAILDIR_PATH}:|g" /etc/virtual/$i/passwd
            fi
			if ${DEFAULT_DOMAIN} && ${DEFAULT_MAIL_MOVED}; then
				if ! grep -m1 -q "^$1:" /etc/virtual/$i/passwd; then
					grep "^$2:" /etc/virtual/$i/passwd | perl -p0 -e "s|:/.*/$2:|:${MAIL_FOLDER}:|g" | perl -p0 -e "s|^$2:|$1:|g" >> /etc/virtual/$i/passwd
				fi
			fi
		fi

		if [ -e /etc/virtual/$i/reply/$1.msg ]; then
			mv -f /etc/virtual/$i/reply/$1.msg /etc/virtual/$i/reply/$2.msg
		fi
		if [ -e /etc/virtual/$i/reply/$1.msg_off ]; then
			mv -f /etc/virtual/$i/reply/$1.msg_off /etc/virtual/$i/reply/$2.msg_off
		fi
		if [ -e /etc/virtual/$i/majordomo ]; then
			mailing_list_swap $1 $2 /etc/virtual/$i/majordomo/list.aliases
			mailing_list_swap $1 $2 /etc/virtual/$i/majordomo/private.aliases
		fi
		
		#/etc/dovecot/conf/sni/domain.com.conf
		SNI_CONF=/etc/dovecot/conf/sni/${i}.conf
		if [ -s ${SNI_CONF} ]; then
			TEMP="/usr/bin/perl -pi -e 's#${DATA_USER_OLD}#${DATA_USER_NEW}/#g' ${SNI_CONF}"
			eval $TEMP;
		fi
	};
	done;
}

ftp_path_swap()
{
	if [ ! -s "$3" ]; then
		return;
	fi

	TEMP="/usr/bin/perl -pi -e 's#users/${1}/ftp.passwd#users/${2}/ftp.passwd#g' $3"
	eval $TEMP;
}

ftp_swap()
{
	#/etc/proftpd.passwd
	#/etc/proftpd.vhosts.conf
	ftp_path_swap $1 $2 /etc/proftpd.vhosts.conf
	ftp_pass_swap $1 $2 /etc/proftpd.passwd
	ftp_pass_swap $1 $2 ${DA_DATA_USERS}/$1/ftp.passwd

	TEMP="/usr/bin/perl -pi -e 's#users/${1}/#users/${2}/#g' ${DA_DATA_USERS}/$1/domains/*.ftp";
	eval $TEMP;

	TEMP="/usr/bin/perl -pi -e 's#${OHOME}/#${NHOME}/#g' ${DA_DATA_USERS}/$1/domains/*.ftp";
	eval $TEMP;
	
	if [ -s /etc/pureftpd.pdb ] && [ -x ${PURE_PW} ]; then
		${PURE_PW} mkdb /etc/pureftpd.pdb -f /etc/proftpd.passwd
	fi
}

httpd_swap()
{
	#/etc/httpd/conf/httpd.conf
	#/etc/httpd/conf/ips.conf
	#/usr/local/directadmin/data/users/$1/httpd.conf
	
	if [ ! -s /etc/httpd/conf/httpd.conf ]; then
		return;
	fi

	TEMP="/usr/bin/perl -pi -e 's#users/${1}/httpd.conf#users/${2}/httpd.conf#g' /etc/httpd/conf/httpd.conf";
	eval $TEMP;
	TEMP="/usr/bin/perl -pi -e 's#users/${1}/httpd.conf#users/${2}/httpd.conf#g' /etc/httpd/conf/extra/directadmin-vhosts.conf";
	eval $TEMP;

	#maybe it's nginx
	if [ -s /etc/nginx/directadmin-vhosts.conf ]; then
		TEMP="/usr/bin/perl -pi -e 's#users/${1}/nginx.conf#users/${2}/nginx.conf#g' /etc/nginx/directadmin-vhosts.conf";
		eval $TEMP;		
	fi
	
	#I thought about doing the ips.conf and the users httpd.conf file.
	#but figured it would be far safer to just issue a rewrite.
	
	TEMP="/usr/bin/perl -pi -e 's#=${1}\$#=${2}#g' ${DA_DATA_USERS}/$1/domains/*.conf";
	eval $TEMP;
	
	TEMP="/usr/bin/perl -pi -e 's#users/${1}/#users/${2}/#g' ${DA_DATA_USERS}/$1/domains/*.conf";
	eval $TEMP;
}

nginx_swap()
{
	if [ ! -s /etc/nginx/directadmin-vhosts.conf ]; then
		return;
	fi

	#/etc/nginx/directadmin-vhosts.conf
	TEMP="/usr/bin/perl -pi -e 's#users/${1}/nginx.conf#users/${2}/nginx.conf#g' /etc/nginx/directadmin-vhosts.conf";
	eval $TEMP;
}

mysql_swap()
{
	#well, im going to say it outright.. this might not be so easy.
	#have to rename all the databases and all users from username_something to newuser_something.
	#1) stop mysql.  Do this by killing the pid.  Remember to set it to OFF in the services.status file.
	#2) rename the database directory
	#3) start up mysql again
	
	
	#use the change_database_username.sh script.
	MYSQL_CONF=/usr/local/directadmin/conf/mysql.conf
	MYSQL_USER=`cat $MYSQL_CONF | grep user | cut -d= -f2`
	MYSQL_PASS=`cat $MYSQL_CONF | grep passwd | cut -d= -f2`
	DBHOST=localhost
	if [ `grep -c ^host= $MYSQL_CONF` -gt 0 ]; then
		DBHOST=`cat $MYSQL_CONF | grep ^host= | cut -d= -f2`
	fi
	VERBOSE=$VERBOSE DBUSER="$MYSQL_USER" DBPASS="$MYSQL_PASS" DBHOST="$DBHOST" USERNAME="$1" NEWUSERNAME="$2" /usr/local/bin/php -c /usr/local/directadmin/scripts/php_clean.ini /usr/local/directadmin/scripts/change_database_username.php
}

mysql_swap_in_public_html()
{
	MY_CNF=/usr/local/directadmin/conf/my.cnf
	for database_name in `mysql --defaults-extra-file=${MY_CNF} -e "SHOW DATABASES LIKE '${2}_%';" -sss`; do {
		OLD_DB_NAME=`echo "${database_name}" | perl -p0 -e "s|^${2}_|${1}_|g"`
		echo "Trying to find files in public_html to rename ${OLD_DB_NAME} to ${database_name}. A copy of the file will have '.change_username_copy_dbname.php' appended at the end."
		find ${NHOME}/domains/*/public_html -maxdepth 3 \( -name "*.php" -o -name '.env' \) ! -name '*.change_username_copy.php' ! -name '*.change_username_copy_dbname.php' -exec grep -m1 -l "${OLD_DB_NAME}" {} \; -exec cp -pf {} "{}.change_username_copy_dbname.php" \; -exec perl -pi -e "s|${OLD_DB_NAME}|${database_name}|g" {} \;
	}
	done
	for mysql_user in `mysql --defaults-extra-file=${MY_CNF} -e "select distinct user from mysql.user where user like '${2}_%';" -sss`; do {
		if ! mysql --defaults-extra-file=${MY_CNF} -e "SHOW DATABASES LIKE '${mysql_user}';" -sss | grep -m1 -q "^${mysql_user}$"; then
			OLD_DB_USERNAME=`echo "${mysql_user}" | perl -p0 -e "s|^${2}_|${1}_|g"`
			echo "Trying to find files in public_html to rename ${OLD_DB_USERNAME} to ${mysql_user}. A copy of the file will have '.change_username_copy.php' appended at the end."
			find ${NHOME}/domains/*/public_html -maxdepth 3 \( -name "*.php" -o -name '.env' \) ! -name '*.change_username_copy.php' ! -name '*.change_username_copy_dbname.php' -exec grep -m1 -l "${OLD_DB_USERNAME}" {} \; -exec cp -pf {} "{}.change_username_copy.php" \; -exec perl -pi -e "s|${OLD_DB_USERNAME}|${mysql_user}|g" {} \;
		fi
	}
	done
}

da_swap()
{
	#email
	#ftp
	#httpd
	#./data/users/reseller/users.list
	#./data/users/client/user.conf->creator=$1 -> $2
	#./data/users/username and *

	email_swap $1 $2
	ftp_swap $1 $2
	httpd_swap $1 $2
	nginx_swap $1 $2
	mysql_swap $1 $2
	mysql_swap_in_public_html $1 $2
	if [ -e /usr/local/awstats ]; then
		awstats_swap $1 $2
	fi
	installatron_swap $1 $2

	CREATOR=`grep creator= ${DA_DATA_USERS}/$1/user.conf | cut -d= -f2`
	if [ "$CREATOR" != "root" ]; then
		generic_swap $1 $2 ${DA_DATA_USERS}/$CREATOR/users.list
	fi
	
	if [ -e ${DA_DATA_USERS}/$1/reseller.conf ]; then
		generic_swap $1 $2 /usr/local/directadmin/data/admin/reseller.list
		TEMP="/usr/bin/perl -pi -e 's#reseller=${1}\$#reseller=${2}#g' /usr/local/directadmin/data/admin/ips/*";
		eval $TEMP;
		
		#change the creator for all accounts we've made.
		for i in `cat ${DA_DATA_USERS}/$1/users.list`; do
		{
			TEMP="/usr/bin/perl -pi -e 's#creator=${1}\$#creator=${2}#g' ${DA_DATA_USERS}/$i/user.conf";
			eval $TEMP;
		};
		done;
		
		#now check to see if we are an admin too.  If so, change any resellers/admins who have us as their creator.
		TYPE=`grep usertype= ${DA_DATA_USERS}/$1/user.conf | cut -d= -f2`
		if [ "$TYPE" = "admin" ]; then
			for i in `cat /usr/local/directadmin/data/admin/reseller.list; cat /usr/local/directadmin/data/admin/admin.list`; do
			{
				TEMP="/usr/bin/perl -pi -e 's#creator=${1}\$#creator=${2}#g' ${DA_DATA_USERS}/$i/user.conf";
				eval $TEMP;
			};
			done;
			
			generic_swap $1 $2 /usr/local/directadmin/data/admin/admin.list			
		fi

		#to be safe, rewrite the whole pile with the updated creator, in case anyone is suspended.
		echo "action=rewrite&value=httpd" >> ${TASKQ}
	fi
	TEMP="/usr/bin/perl -pi -e 's#value=${1}\$#value=${2}#g' /usr/local/directadmin/data/admin/ips/*";
	eval $TEMP;

	TEMP="/usr/bin/perl -pi -e 's#username=${1}\$#username=${2}#g' ${DA_DATA_USERS}/$1/user.conf";
	eval $TEMP;

	mv -f ${DA_DATA_USERS}/$1 ${DA_DATA_USERS}/$2

	#once done, rewrite the ips.conf and users httpd.conf using $2
	#show all users cache. Total rewrite.
	
	echo "action=rename&value=username&username=${2}&old_username=${1}&old_home=${OHOME}" >> ${TASKQ_CB};
	${DATASKQ_BIN} --custombuild
	
	echo "action=rewrite&value=httpd&user=$2" >> ${TASKQ}
	echo "action=rewrite&value=ips" >> ${TASKQ}
	echo "action=cache&value=showallusers" >> ${TASKQ}

}

change_name()
{
	security_check $1
	security_check $2
	ensure_user $1
	prevent_user $2

	system_swap $1 $2
	da_swap $1 $2
    if [ -x /usr/sbin/cagefsctl ]; then
        /usr/sbin/cagefsctl --remount ${2}
    fi
}

if [ $# -eq 2 ]; then
	change_name $1 $2
	exit 0
fi
