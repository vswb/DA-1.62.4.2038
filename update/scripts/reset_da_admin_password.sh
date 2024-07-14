#!/bin/sh
#Use existing passwords to reset the da_admin account password.
#https://www.directadmin.com/features.php?id=2677

ROOT_LOGIN=root
ROOT_PASS=

DA_ADMIN=da_admin
DA_ADMIN_PASS=

MYSQL_HOST=localhost

SETUP_TXT=/usr/local/directadmin/scripts/setup.txt
MYSQL_CONF=/usr/local/directadmin/conf/mysql.conf
MY_CNF=/usr/local/directadmin/conf/my.cnf

TMP_MY_CNF=/root/.tmp_my_cnf
TMP_SQL=/root/.tmp.sql

###############################
# FUNCTIONS

set_my_cnf() {
	CNF=$1
	CL=$2
	CP=$3
	CH=$4

	echo -n ''          > ${CNF}
	chmod 600             ${CNF}
	echo "[client]"    >> ${CNF}
	echo "user=$CL"     >> ${CNF}
	echo "password=$CP" >> ${CNF}
	echo "host=$CH" >> ${CNF}
}

#return 0 for success
test_login() {
	L=$1
	P=$2

	set_my_cnf "${TMP_MY_CNF}" "$L" "$P" "$MYSQL_HOST"
	
	RES=`mysql --defaults-extra-file=${TMP_MY_CNF} -e "quit"`
	R=$?
	
	/bin/rm -f ${TMP_MY_CNF}

	return $R
}

set_host_vars() {
	if [ -s ${MYSQL_CONF} ]; then
		TEST_HOST=`grep ^host= ${MYSQL_CONF} | cut -d= -f2`
		if [ "${TEST_HOST}" != "" ]; then
			MYSQL_HOST=${TEST_HOST}
			echo "Using host=${MYSQL_HOST}"
		fi
		
		if [ "${MYSQL_HOST}" != "localhost" ]; then
			echo "This script currently only supports resetting local da_admin accounts.  For remote accounts, please to this manually, accounting for access hosts."
			exit 4
		fi
		
		#in case some other account name is used.
		TEST_DA_ADMIN=`grep ^user= ${MYSQL_CONF} | cut -d= -f2`
		if [ "${TEST_DA_ADMIN}" != "" ]; then
			DA_ADMIN=${TEST_DA_ADMIN}
		fi
	fi
}

#find a currently working login
#return 0 for success
set_root_login_vars() {
	if [ -s ${SETUP_TXT} ]; then
		ROOT_PASS=`grep '^mysql=' ${SETUP_TXT} | cut -d= -f2`
		
		test_login "$ROOT_LOGIN" "$ROOT_PASS"
		if [ "$?" -eq 0 ]; then
			echo "Using 'mysql=' ${ROOT_LOGIN} pass from ${SETUP_TXT}"
			return 0
		fi
	fi
	
	if [ -s ${MYSQL_CONF} ]; then
		ROOT_LOGIN=`grep '^user=' ${MYSQL_CONF} | cut -d= -f2`
		ROOT_PASS=`grep '^passwd=' ${MYSQL_CONF} | cut -d= -f2`
		
		test_login "$ROOT_LOGIN" "$ROOT_PASS"
		if [ "$?" -eq 0 ]; then
			echo "Using 'passwd=' ${DA_ADMIN} pass from ${MYSQL_CONF}"
			return 0
		fi
	fi

	#still no go?
	if [ -s ${SETUP_TXT} ]; then
		ROOT_LOGIN=`grep '^mysqluser=' ${SETUP_TXT} | cut -d= -f2`
		ROOT_PASS=`grep '^adminpass=' ${SETUP_TXT} | cut -d= -f2`
		test_login "$ROOT_LOGIN" "$ROOT_PASS"
		if [ "$?" -eq 0 ]; then
			echo "Using 'adminpass=' ${ROOT_LOGIN} pass from ${SETUP_TXT}"
			return 0
		fi
	fi
	
	#check any other ideas here.
	
	echo "Could not find any working logins for ${MYSQL_HOST}"
	
	return 1
}
set_pass_stdin() {
	read DA_ADMIN_PASS
}

#from setup.sh
random_pass() {
	PASS_LEN=`perl -le 'print int(rand(6))+9'`
	START_LEN=`perl -le 'print int(rand(8))+1'`
	END_LEN=$(expr ${PASS_LEN} - ${START_LEN})
	SPECIAL_CHAR=`perl -le 'print map { (qw{@ ^ _ - /})[rand 6] } 1'`;
	NUMERIC_CHAR=`perl -le 'print int(rand(10))'`;
	PASS_START=`perl -le "print map+(A..Z,a..z,0..9)[rand 62],0..$START_LEN"`;
	PASS_END=`perl -le "print map+(A..Z,a..z,0..9)[rand 62],0..$END_LEN"`;
	PASS=${PASS_START}${SPECIAL_CHAR}${NUMERIC_CHAR}${PASS_END}
	echo $PASS
}

set_pass_random() {
	DA_ADMIN_PASS=`random_pass`
}

set_pass_var() {
	DA_ADMIN_PASS=$1
}

validate_password() {
	P=${DA_ADMIN_PASS}
	if [ "$P" = "" ]; then
		echo "Password is blank"
		return 1
	fi

	return 0
}

set_password_in_mysql() {
	
	set_my_cnf "${TMP_MY_CNF}" "$ROOT_LOGIN" "$ROOT_PASS" "$MYSQL_HOST"
	
	USE_HOST=localhost
	
	echo -n '' > ${TMP_SQL}
	chmod 600 ${TMP_SQL};
	echo "ALTER USER ${DA_ADMIN}@${USE_HOST} IDENTIFIED BY '${DA_ADMIN_PASS}';" >> ${TMP_SQL};
	
	RES=`mysql --defaults-extra-file=${TMP_MY_CNF} < ${TMP_SQL}`
	R=$?
	
	if [ "$R" -ne 0 ]; then
		echo "Error running password update for ${DA_ADMIN}@${USE_HOST}"
		echo ${RES}
	fi
	
	/bin/rm -f ${TMP_MY_CNF}
	/bin/rm -f ${TMP_SQL}
	
	return $R
}

set_new_pass_to_configs() {
	if [ -s ${MYSQL_CONF} ]; then
		perl -pi -e "s/^passwd=.*/passwd=${DA_ADMIN_PASS}/" ${MYSQL_CONF}
	else
		echo -n '' > ${MYSQL_CONF}
		chmod 600 ${MYSQL_CONF}
		chown diradmin:diradmin ${MYSQL_CONF}
		echo "user=${DA_ADMIN}" >> ${MYSQL_CONF}
		echo "passwd=${DA_ADMIN_PASS}" >> ${MYSQL_CONF}
		#echo host
	fi
	
	if [ -s ${MY_CNF} ]; then
		perl -pi -e "s/^password=.*/password=${DA_ADMIN_PASS}/" ${MY_CNF}
	else
		echo -n '' > ${MY_CNF}
		chmod 600 ${MY_CNF}
		chown diradmin:diradmin ${MY_CNF}
		echo "[client]"
		echo "user=${DA_ADMIN}" >> ${MY_CNF}
		echo "password=${DA_ADMIN_PASS}" >> ${MY_CNF}	
		#echo host
	fi
}

show_help() {

	echo "Usage:"
    echo "    $0 --stdin               - the password will be passed on stdin"
    echo "    $0 --random              - pick a new random password"
    echo "    $0 --password 'newpass'  - set to specified password'"
    echo "    $0                       - this help page"
}

# END FUNCTIONS
###############################
#
# MAIN START
#

case "$1" in
	'--stdin')  set_pass_stdin
				;;
	'--random') set_pass_random
				;;
	'--password') set_pass_var "$2"
				;;
			*) show_help;
				exit 2
				;;
esac



set_host_vars
set_root_login_vars
if [ "$?" -ne 0 ]; then
	echo "Could not find a working root/da_admin login to use for the reset. Aborting"
	exit 1
fi

#At this point, we have a working: ROOT_LOGIN@MYSQL_HOST with ROOT_PASS.
validate_password
if [ "$?" -ne 0 ]; then
	echo "Password '$DA_ADMIN_PASS' is not valid. Aborting"
	exit 3
fi

set_password_in_mysql
if [ "$?" -ne 0 ]; then
	exit 5
fi

set_new_pass_to_configs

echo "Success!"
exit 0;
