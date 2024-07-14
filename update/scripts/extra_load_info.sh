#!/bin/sh
OS=`uname`
BIN_PS=/bin/ps
if [ -x ${BIN_PS} ]; then
	echo "Top Memory Usage:"
	${BIN_PS} aux | sort -r -nk 4 | head
fi

VMSTAT=/usr/bin/vmstat
if [ -x ${VMSTAT} ]; then
	echo ""
	echo "Virtual Memory Info:"
	
	if [ "${OS}" = "FreeBSD" ]; then
		${VMSTAT} 1 3
	else
		HAS_TIMESTAMP=`${VMSTAT} --help 2>&1 | grep -c '\-t'`
	
		if [ "${HAS_TIMESTAMP}" = "0" ]; then
			date
			${VMSTAT} -w 1 3
			date
		else
			${VMSTAT} -tw 1 3
		fi
	fi
fi

MYSQLD_COUNT=`ps ax | grep -v grep | grep -c mysqld`
if [ "${MYSQLD_COUNT}" -gt 0 ]; then
	DA_MYSQL=/usr/local/directadmin/conf/mysql.conf
	DA_MY_CNF=/usr/local/directadmin/conf/my.cnf
	if [ -s $DA_MYSQL ] && [ `grep -m1 -c -e "^host=" ${DA_MYSQL}` -gt "0" ]; then
		MYSQLHOST=`grep -m1 "^host=" ${DA_MYSQL} | cut -d= -f2`
	else
		MYSQLHOST=localhost
	fi

	#only check if it's local
	if [ "${MYSQLHOST}" = "localhost" ]; then
		echo ""
		echo "Current MySQL Queries"
		mysql --defaults-extra-file=${DA_MY_CNF} -sse "SHOW FULL PROCESSLIST;" --host=${MYSQLHOST}
	fi
fi

exit 0;