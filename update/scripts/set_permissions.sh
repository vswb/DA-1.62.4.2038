#!/bin/sh

# Script to set the file ownerships and
# permissions of all DA related files on 
# the system.  Should be quite useful
# for system restores, just make sure
# that the user accounts have already
# been created in the /etc/passwd,
# /etc/shadow, /etc/group files.

OS=`uname`
ECHO_LOG=1;
SAVE_LOG=1;
LOG=/tmp/set_perm.log
ERRLOG=/tmp/set_perm.err.log

DAPATH=/usr/local/directadmin

RT_GRP="root";
if [ "$OS" = "FreeBSD" ]; then
	RT_GRP="wheel";
fi

DOVECOT=`grep -c 'dovecot=1' ${DAPATH}/conf/directadmin.conf`
DIRECTADMIN=${DAPATH}/directadmin

HAVE_HTTPD=1
HAVE_NGINX=0
if [ -s ${DIRECTADMIN} ]; then
	if [ "`${DIRECTADMIN} c | grep ^nginx= | cut -d= -f2`" -eq 1 ]; then
		HAVE_HTTPD=0
		HAVE_NGINX=1
	fi
	if [ "`${DIRECTADMIN} c | grep ^nginx_proxy= | cut -d= -f2`" -eq 1 ]; then
		HAVE_HTTPD=1
		HAVE_NGINX=1
	fi
fi

show_help()
{
	echo "";
	echo "DirectAdmin File Permission/Ownership script";
	echo "";
	echo "Usage:";
	echo "  $0 all";
	echo "  $0 all_with_domaindirs";
	echo "";
	echo "  $0 da_files"; #don't forget /home/tmp
	echo "  $0 domaindirs";
	echo "  $0 user_homes";
	echo "  $0 mysql";
	echo "  $0 email";
	echo "  $0 logs";
	echo "  $0 etc_configs";
	echo "";
	echo "internal:";
	echo "  $0 maildir <user> <path/Maildir>";
	echo "  $0 set_user_home <user>";
	echo "  $0 domaindir <domainname> [<user>]; user could be skipped";
	echo "";
}

#writes to log file
log()
{
	if [ $SAVE_LOG -eq 1 ]; then
		echo "$1" >> $LOG;
	fi
	if [ $ECHO_LOG -eq 1 ]; then
		echo "$1";
	fi
}

error_log()
{
	echo "Error: $1";
	echo "$1" >> $ERRLOG
	log "$1"
}

###########
# set_file /file user group 755  -R
##########
set_file()
{
	if [ -e "$1" ] || [ "$6" = "nocheck" ]; then
		log "set $1 $2:$3 $4 flag $5";

		#chown goes first.
		#A 4755 file is set to 755 if chown is called after chmod.

		#if there is an asterisk, no quotes.
		if echo x"$1" | grep '*' > /dev/null; then
			chown $5 $2:$3 $1
			chmod $5 $4 $1			
		else
			chown $5 $2:$3 "$1"
			chmod $5 $4 "$1"
		fi
	fi

}

###########################################
# gets a list of the DA users on the system
all_users()
{
	for i in `ls $DAPATH/data/users`; do
	{
		if [ -e $DAPATH/data/users/$i/user.conf ]; then
			echo -n "$i ";
		fi
	};
	done;
}

set_user_perm()
{
	log "set_user_perm $1";
	DIR=$DAPATH/data/users/$1
	set_file $DIR diradmin diradmin 711
	set_file $DIR/bandwidth.tally root $RT_GRP 600
	set_file $DIR/ftp.passwd root ftp 640
	set_file $DIR/crontab.conf diradmin diradmin 600
	set_file $DIR/domains.list diradmin diradmin 600
	set_file $DIR/domains diradmin diradmin 711
	set_file $DIR/httpd.conf diradmin $1 640
	set_file $DIR/nginx.conf diradmin $1 640
	set_file $DIR/openlitespeed.conf diradmin lsadmn 640
	set_file $DIR/ticket.conf diradmin diradmin 600
	set_file $DIR/tickets.list diradmin diradmin 600
	set_file $DIR/user.conf diradmin diradmin 600
	set_file $DIR/user.usage diradmin diradmin 600
	set_file $DIR/user.history diradmin diradmin 600
	set_file $DIR/user.comments diradmin diradmin 600
	set_file $DIR/user_ip.list diradmin diradmin 600
	set_file $DIR/login.hist diradmin diradmin 600
	set_file $DIR/twostep_auth_secret.txt diradmin diradmin 600
	set_file $DIR/twostep_auth_scratch_codes.list diradmin diradmin 600
	set_file $DIR/login_keys diradmin diradmin 700
	set_file $DIR/skin_customizations diradmin diradmin 711
	set_file $DIR/history diradmin diradmin 700
	set_file "$DIR/history/*" diradmin diradmin 600 '' nocheck
	
	
	#hmm... do we want to rebuild the files?.. bit more than just "set permissions"
	
	for j in `cat $DIR/domains/*.conf | grep -e '^domain=' | cut -d= -f2`; do
	{
		COUNT=`cat $DIR/domains.list | grep -c $j`
		if [ $COUNT -eq 0 ]; then
			log "Found missing domain $j for user $1";
			echo $j >> $DIR/domains.list
		fi
	};
	done;
	
	if [ -d "${DIR}/domains" ]; then
		find "${DIR}/domains" -type d -exec chmod 711 {} \; -exec chown diradmin:diradmin {} \;
		find "${DIR}/domains" -type f -exec chmod 600 {} \; -exec chown diradmin:diradmin {} \;
	fi

	SAC=`/usr/local/directadmin/directadmin c |grep '^secure_access_group=' | cut -d= -f2`
	SSL_PERM=640
	#if [ "${SAC}" = "" ]; then
	#	SAC=diradmin
	#	SSL_PERM=644
	#fi
	SAC=mail

	set_file "$DIR/domains/*.cert" diradmin ${SAC} 640 '' nocheck
	set_file "$DIR/domains/*.cacert" diradmin ${SAC} 640 '' nocheck
	set_file "$DIR/domains/*.cert.combined" diradmin ${SAC} 640 '' nocheck
	set_file "$DIR/domains/*.key" diradmin ${SAC} 640 '' nocheck
}

set_reseller_perm()
{
	log "set_reseller_perm $1";
	DIR=$DAPATH/data/users/$1
	set_file $DIR/ip.list diradmin diradmin 600
	set_file $DIR/packages diradmin diradmin 600 -R
	set_file $DIR/packages diradmin diradmin 700
	set_file $DIR/packages.list diradmin diradmin 600
	set_file $DIR/reseller.allocation diradmin diradmin 600
	set_file $DIR/reseller.conf diradmin diradmin 600
	set_file $DIR/reseller.usage diradmin diradmin 600
	set_file $DIR/reseller.history diradmin diradmin 600
	set_file $DIR/u_welcome.txt diradmin diradmin 600
	set_file $DIR/bandwidth.tally.cache diradmin diradmin 600

	set_file $DIR/users.list diradmin diradmin 600
	set_file $DIR/reseller.history diradmin diradmin 600
	
}

set_admin_perm()
{
	log "set_admin_perm"
	DIR=$DAPATH/data/admin
	
	if [ -d "${DIR}" ]; then
		find "${DIR}" -type d -exec chmod 700 {} \; -exec chown diradmin:diradmin {} \;
		find "${DIR}" -type f -exec chmod 600 {} \; -exec chown diradmin:diradmin {} \;
	fi
	set_file $DIR/ip_access diradmin diradmin 700
	set_file $DIR/ips diradmin diradmin 700
	set_file $DIR/packages diradmin diradmin 700
	set_file $DIR/task_queue_processes diradmin diradmin 700
}

da_files()
{
	set_file /home/tmp root $RT_GRP 1777
	set_file $DAPATH diradmin diradmin 755
	if [ -d "${DAPATH}/conf" ]; then
		find "${DAPATH}/conf" -type d -exec chmod 700 {} \; -exec chown diradmin:diradmin {} \;
		find "${DAPATH}/conf" -type f -exec chmod 600 {} \; -exec chown diradmin:diradmin {} \;
	fi
	
	if [ -e $DAPATH/directadmin ]; then
		$DAPATH/directadmin p
	fi

	for i in `all_users`; do
	{
		set_user_perm $i
		
		if [ -e $DAPATH/data/users/$i/reseller.conf ]; then
			set_reseller_perm $i		
		fi	
	};
	done;

	set_file $DAPATH/data/users diradmin diradmin 711

	set_admin_perm;
	
	if [ -d "${DAPATH}/data/sessions" ]; then
		find "${DAPATH}/data/sessions" -type d -exec chmod 700 {} \; -exec chown diradmin:diradmin {} \;
		find "${DAPATH}/data/sessions" -type f -exec chmod 600 {} \; -exec chown diradmin:diradmin {} \;
	fi

	#set_file $DAPATH/data/tickets diradmin diradmin 700 -R
	#set_file "$DAPATH/data/tickets/*" diradmin diradmin 700
	#set_file "$DAPATH/data/tickets/*/*" diradmin diradmin 700
	#set_file "$DAPATH/data/tickets/*/*/*" diradmin diradmin 600 '' nocheck
	if [ -d "${DAPATH}/data/tickets" ]; then
		find "${DAPATH}/data/tickets" -type d -exec chmod 700 {} \; -exec chown diradmin:diradmin {} \;
		find "${DAPATH}/data/tickets" -type f -exec chmod 600 {} \; -exec chown diradmin:diradmin {} \;
	fi
}

set_user_home()
{
	log "set_user_home $1";
	UHOME=`grep -e "^${1}:" /etc/passwd | cut -d: -f6`
	
	if [ "$UHOME" = "" ]; then
		log "Home directory for $1 is empty. Check the /etc/passwd file, make sure the account exists";
		return;
	fi
	#Some users might be using file, not folder as homedir. For example - jetbackups uses /dev/null
	if [ -d $UHOME ]; then
		#chown other-user owned files to user in usr's home directory (commented out for now)
		#find $UHOME -not -user apache -not -user $1 -not -user root -not -user mail -exec chown ${i}:${i} {} \;
		set_file $UHOME $1 $1 711
		set_file $UHOME/.shadow $1 mail 640
		set_file $UHOME/domains $1 $1 711
		set_file "$UHOME/domains/*" $1 $1 711 '' nocheck
		set_file $UHOME/domains/default $1 $1 755
		set_file $UHOME/domains/sharedip $1 $1 755
		set_file $UHOME/domains/suspended $1 $1 755
		set_file $UHOME/backups $1 $1 700
		set_file "$UHOME/backups/*" $1 $1 600 '' nocheck
		set_file $UHOME/user_backups $1 $1 711
		set_file "$UHOME/user_backups/*" $1 $1 755 '' nocheck
		if [ -d "${UHOME}/imap" ]; then
			find "${UHOME}/imap" -type d -exec chmod 770 {} \; -exec chown ${1}:mail {} \;
			find "${UHOME}/imap" -type f -exec chmod 660 {} \; -exec chown ${1}:mail {} \;
		fi
		if [ -d "${UHOME}/.trash" ]; then
			find "${UHOME}/.trash" -type d -exec chmod 770 {} \; -exec chown ${1}:mail {} \;
			find "${UHOME}/.trash" -type f -exec chmod 660 {} \; -exec chown ${1}:mail {} \;
		fi
		set_file $UHOME/.spamassassin $1 mail 771
		set_file $UHOME/.spamassassin/spam $1 mail 660
		set_file $UHOME/.spamassassin/user_spam $1 mail 771
		set_file "$UHOME/.spamassassin/user_spam/*" mail $1 660
	fi
	
	# not sure how much else we should do.. the public_html and cgi-bins 
	# should really be left untouched in case of any custom permission
	# like being owned by apache, or 777 etc.

	#reset for secure_access_group
	SAC=`grep -c secure_access_group /usr/local/directadmin/conf/directadmin.conf`
	if [ "$SAC" -gt 0 ]; then
		echo "action=rewrite&value=secure_access_group" >> /usr/local/directadmin/data/task.queue
	fi
}

user_homes()
{
	log "user_homes"
	
	set_file /home root $RT_GRP 711
	
	for i in `all_users`; do
	{
		set_user_home $i
	};
	done;
	
}

do_mysql()
{
	log "do_mysql";
	
	MDIR=/var/lib/mysql
	
	if [ "$OS" = "FreeBSD" ]; then
		if [ -e /home/mysql ]; then
			MDIR=/home/mysql
		else
			MDIR=/usr/local/mysql/data
		fi
	fi
	if [ -e /etc/debian_version ]; then
                if [ -e /home/mysql ]; then
                        MDIR=/home/mysql
                else
                        MDIR=/usr/local/mysql/data
                fi
        fi

        find $MDIR -type d -exec chmod 700 {} \; -exec chown mysql:mysql {} \;
        find $MDIR -type f -exec chmod 660 {} \; -exec chown mysql:mysql {} \;
	
	set_file "${MDIR}*" mysql mysql 711 '' nocheck
}

get_domain_user()
{
	if [ "$1" = "" ]; then
		error_log "get_domain_user: no domain passed";
		echo "";
		return;
	fi

	USERN=`grep -e "^$1:" /etc/virtual/domainowners | cut -d\  -f2`
	if [ "$USERN" = "" ]; then
		error_log "can't find user for $1 in /etc/virtual/domainowners";
			echo "";
		return;
	fi

	echo "$USERN";
}

set_maildir()
{
	if [ "$2" = "" ]; then
		log "***Warning empty Maildir string***";
		return;
	fi

	if [ ! -e $2 ]; then
		log "cannot find $2 : skipping";
		return;
	fi

	user=$1;
	md=$2;
	
	set_file $md $user mail 770
	chown -R $user:mail $md

	OLD_EL=$ECHO_LOG
	ECHO_LOG=0

	find $md -type d -exec chmod 770 {} \; -exec chown $user:mail {} \;
	find $md -type f -exec chmod 660 {} \; -exec chown $user:mail {} \;

	ECHO_LOG=$OLD_EL
}

set_domaindir()
{
	if [ "$1" = "" ]; then
		log "***Warning empty domainname string***"
		show_help
		return
	fi

	if [ "$2" = "" ]; then
		USERN=`get_domain_user $1`
		if [ "$USERN" = "" ]; then
			log "***Warning cannot get user for domain $1***"
			return
		fi
	else
		USERN="$2"
	fi

	HOMEDIR=`getent passwd "$USERN" | cut -d: -f6`;
	
	DOMAINDIR="${HOMEDIR}/domains/${1}"

	if [ ! -e $DOMAINDIR ]; then
			log "cannot find $DOMAINDIR : skipping";
			return;
	fi

	log "Directories found, setting permissions for ${DOMAINDIR}/public_html and private_html"
	
	if [ -d "${DOMAINDIR}/public_html" ]; then
		find "${DOMAINDIR}/public_html" -type d -exec chmod 755 {} \; -exec chown ${USERN}:${USERN} {} \;
		find "${DOMAINDIR}/public_html" -type f -exec chmod 644 {} \; -exec chown ${USERN}:${USERN} {} \;
	fi

	if [ -d "${DOMAINDIR}/public_ftp" ]; then
		find "${DOMAINDIR}/public_ftp" -type d -exec chmod 755 {} \; -exec chown ${USERN}:${USERN} {} \;
		find "${DOMAINDIR}/public_ftp" -type f -exec chmod 644 {} \; -exec chown ${USERN}:${USERN} {} \;
	fi

	if [ -d "${DOMAINDIR}/logs" ]; then
		find "${DOMAINDIR}/logs" -type d -exec chmod 755 {} \; -exec chown ${USERN}:${USERN} {} \;
		find "${DOMAINDIR}/logs" -type f -exec chmod 644 {} \; -exec chown ${USERN}:${USERN} {} \;
	fi

	if [ -d "${DOMAINDIR}/.htpasswd" ]; then
		find "${DOMAINDIR}/.htpasswd" -type d -exec chmod 755 {} \; -exec chown ${USERN}:${USERN} {} \;
		find "${DOMAINDIR}/.htpasswd" -type f -exec chmod 644 {} \; -exec chown ${USERN}:${USERN} {} \;
	fi

	if [ -d "${DOMAINDIR}/stats" ]; then
		find "${DOMAINDIR}/stats" -type d -exec chmod 755 {} \; -exec chown ${USERN}:${USERN} {} \;
		find "${DOMAINDIR}/stats" -type f -exec chmod 644 {} \; -exec chown ${USERN}:${USERN} {} \;
	fi

	if [ -L "${DOMAINDIR}/private_html" ]; then
		chown -h ${USERN}:${USERN} "${DOMAINDIR}/private_html"
	elif [ -d "${DOMAINDIR}/private_html" ]; then
		find "${DOMAINDIR}/private_html" -type d -exec chmod 755 {} \; -exec chown ${USERN}:${USERN} {} \;
		find "${DOMAINDIR}/private_html" -type f -exec chmod 644 {} \; -exec chown ${USERN}:${USERN} {} \;
	fi

}

set_domaindirs() {
	for user in `ls /usr/local/directadmin/data/users`; do
	{
		for domain in `grep ": $user" /etc/virtual/domainowners | cut -d: -f1`; do
		{
			set_domaindir ${domain} ${user}
		};
		done
	};
	done
}

set_dovecot()
{
	log "dovecot";
	for i in `all_users`; do
	{
		uhome=`grep -e "^${i}:" /etc/passwd | cut -d: -f6`
		if [ "$uhome" = "" ]; then
			continue;
		fi
		$0 maildir $i $uhome/Maildir
		set_file $uhome/imap $i mail 770
		if [ -s /usr/local/directadmin/data/users/${i}/domains.list ]; then
			for domain in `cat /usr/local/directadmin/data/users/${i}/domains.list`; do {
				cat /etc/virtual/${domain}/passwd | cut -d: -f6 | sort | uniq | while read line; do {
					if [ ! -d ${line}/domains ]; then
						chown $user:mail "${line}"
						chmod 770 "${line}"
					fi
					$0 maildir ${i} "${line}/Maildir"
				}
				done
			}
			done
		fi
	};
	done;
}

email()
{
	log "email";
	
	VDIR=/etc/virtual
	HN=`hostname`

	find "$VDIR" -type d -exec chmod 750 {} \; -exec chown mail:mail {} \;
	find "$VDIR" -type f -exec chmod 640 {} \; -exec chown mail:mail {} \;

	set_file $VDIR mail mail 755

	set_file $VDIR/domainowners mail mail 640
	set_file $VDIR/domains mail mail 640
	set_file $VDIR/pophosts mail mail 600
	set_file $VDIR/pophosts_user mail mail 600
	set_file $VDIR/majordomo majordomo daemon 750
	
	set_file $VDIR/bad_sender_hosts mail mail 600
	set_file $VDIR/bad_sender_hosts_ip mail mail 600
	set_file $VDIR/blacklist_domains mail mail 600
	set_file $VDIR/blacklist_senders mail mail 600
	set_file $VDIR/whitelist_domains mail mail 600
	set_file $VDIR/whitelist_hosts mail mail 600
	set_file $VDIR/whitelist_hosts_ip mail mail 600
	set_file $VDIR/whitelist_senders mail mail 600
	set_file $VDIR/use_rbl_domains mail mail 600
	set_file $VDIR/skip_av_domains mail mail 600
	set_file $VDIR/skip_rbl_domains mail mail 600

	for i in `cat /etc/virtual/domainowners | cut -d ":" -f 1`; do
	{
		if [ "$i" = "$HN" ]; then
			continue;
		fi
		
		if [ -d $VDIR/$i ]; then

	                USERN=`get_domain_user $i`;
	                if [ "$USERN" = "" ]; then
        	                USERN="mail";
                	fi

			set_file $VDIR/$i mail mail 711
			DDIR=$VDIR/$i
			set_file $DDIR/aliases mail mail 600
			set_file $DDIR/filter mail mail 640
			set_file $DDIR/filter.conf mail mail 600
			set_file $DDIR/passwd mail mail 600
			set_file $DDIR/quota mail mail 600
			
			set_file $DDIR/dkim.private.key mail mail 600
			set_file $DDIR/dkim.public.key mail mail 600
			set_file $DDIR/dovecot.bytes mail mail 600

			set_file $DDIR/vacation.conf mail mail 600
			set_file $DDIR/autoresponder.conf mail mail 600
			set_file $DDIR/reply mail mail 700
			set_file "$DDIR/reply/*" mail mail 600 '' nocheck
			set_file $DDIR/majordomo majordomo daemon 751
			set_file $DDIR/majordomo/majordomo.cf majordomo daemon 640
			set_file $DDIR/majordomo/list.aliases majordomo mail 640
			set_file $DDIR/majordomo/private.aliases majordomo mail 640
			set_file $DDIR/majordomo/archive majordomo daemon 751
			set_file $DDIR/majordomo/digests majordomo daemon 751
			set_file $DDIR/majordomo/lists majordomo daemon 751
			chown -R majordomo:daemon $DDIR/majordomo/lists
			
		fi
	};
	done;

	if  [ "$DOVECOT" -eq 0 ]; then
		VSV=/var/spool/virtual
		set_file $VSV mail mail 1777

	for i in `all_users`; do
	{
		set_file $VSV/$i $i mail 770
	        set_file "$VSV/$i/*" $i mail 660 '' nocheck

	};
	done;


		SPOOLM=/var/spool/mail
		if [ "$OS" = "FreeBSD" ]; then
			SPOOLM=/var/mail
		fi 
	
		set_file $SPOOLM mail mail 1777

		for i in `all_users`; do
		{
			set_file $SPOOLM/$i $i mail 660
		};
		done;	


	fi

	set_file /var/spool/exim mail mail 750
	set_file "/var/spool/exim/*" mail mail 750 '' nocheck
	#set_file "/var/spool/exim/*/*" mail mail 640 '' nocheck
	chown -R mail:mail /var/spool/exim

	set_file /etc/exim.cert mail mail 644
	set_file /etc/exim.key mail mail 600

	if [ "$DOVECOT" -eq 1 ]; then
		set_dovecot;
	fi

	mkdir -p /var/log/exim
	set_file /var/log/exim mail mail 640 -R
	set_file /var/log/exim mail mail 750

	set_file /usr/sbin/exim root $RT_GRP 4755
}

logs()
{
	log "logs";

	VL=/var/log	

	if [ ! -e $VL/directadmin ]; then
		error_log "$VL/directadmin didn't exists, creating it.";
		mkdir -p $VL/directadmin
	fi

	set_file $VL/directadmin diradmin diradmin 700
	set_file "$VL/directadmin/*" diradmin diradmin 600 '' nocheck

	
	mkdir -p $VL/exim
	set_file $VL/exim mail mail 755
	set_file "$VL/exim/*" mail mail 644 '' nocheck

	mkdir -p $VL/proftpd
	set_file $VL/proftpd root $RT_GRP 755
	set_file "$VL/proftpd/*" root $RT_GRP 644 '' nocheck

	if [ "${HAVE_HTTPD}" -eq 1 ]; then
		#http.. well it's all root, permissions don't really matter
		mkdir -p /var/log/httpd/domains	        
		chmod 710 /var/log/httpd
	        chmod 710 /var/log/httpd/domains
	        chown root:nobody /var/log/httpd/domains
	fi
	if [ "${HAVE_NGINX}" -eq 1 ]; then
		mkdir -p /var/log/nginx/domains
		chmod 710 /var/log/nginx
		chmod 710 /var/log/nginx/domains
		chown root:nobody /var/log/httpd/domains
	fi
}

etc_configs()
{
	log "etc_configs";

	find /etc -name "exim.*" -type d -exec chmod 755 {} \;
    find /etc -name "exim.*" -type f -exec chmod 644 {} \;
    set_file /etc/exim.cert mail mail 644
    set_file /etc/exim.key mail mail 600
	set_file /etc/system_filter.exim root $RT_GRP 755

	set_file /etc/proftpd.conf root $RT_GRP 644
	set_file /etc/proftpd.vhosts.conf root $RT_GRP 644
	set_file /etc/proftpd.passwd root ftp 640

	#httpd.. again, all root.. nothing special about it.
}

all()
{
	da_files;
	user_homes;
	do_mysql;
	email;
	logs;
	etc_configs;
}

all_with_domaindirs() {
	all
	set_domaindirs
}

if [ "$1" != "maildir" ]; then
	log "***********************************************";
	log "`date` : $0 $1";
fi

case "$1" in
	all) all;
		;;

	all_with_domaindirs) all_with_domaindirs;
		;;

	da_files) da_files;
		;;

	user_homes) user_homes;
		;;

	set_user_home) set_user_home $2
		;;

	mysql) do_mysql;
		;;

	email) email;
		;;

	logs) logs;
		;;

	etc_configs) etc_configs;
		;;

	maildir) set_maildir $2 $3;
		;;

    domaindir) set_domaindir $2 $3;
        ;;
	
	domaindirs) set_domaindirs;
        ;;

	*) show_help;
		;;

esac

exit 0;
