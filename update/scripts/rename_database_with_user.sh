#!/bin/sh
#VERSION=0.1
# This script is written by Martynas Bendorius and DirectAdmin
# It is used to move database and it's user from one reseller to another
# Official DirectAdmin webpage: http://www.directadmin.com
# Usage:
# ./rename_database_with_user.sh <olddatabase> <newdatabase>

MYUID=`/usr/bin/id -u`
if [ "$MYUID" != 0 ]; then
        echo "You require Root Access to run this script";
        exit 0;
fi

if [ $# != 2 ]; then
        echo "Usage:";
        echo "$0 <olddatabase> <newdatabase>";
        echo "you gave #$#: $0 $1 $2";
        exit 0;
fi

OLDUSER_DATABASE="$1"
NEWUSER_DATABASE="$2"
OLDUSER_ESCAPED_DATABASE="`echo ${OLDUSER_DATABASE} | perl -p0 -e 's|_|\\\_|'`"
NEWUSER_ESCAPED_DATABASE="`echo ${NEWUSER_DATABASE} | perl -p0 -e 's|_|\\\_|'`"
OLDUSER_ESCAPED_DATABASE_MT="`echo ${OLDUSER_DATABASE} | perl -p0 -e 's|_|\\\\\\\_|'`"
NEWUSER_ESCAPED_DATABASE_MT="`echo ${NEWUSER_DATABASE} | perl -p0 -e 's|_|\\\\\\\_|'`"

MYSQLDUMP=/usr/local/mysql/bin/mysqldump
if [ ! -e ${MYSQLDUMP} ]; then
        MYSQLDUMP=/usr/local/bin/mysqldump
fi
if [ ! -e ${MYSQLDUMP} ]; then
        MYSQLDUMP=/usr/bin/mysqldump
fi
if [ ! -e ${MYSQLDUMP} ]; then
        echo "Cannot find ${MYSQLDUMP}"
        exit 1
fi

MYSQL=/usr/local/mysql/bin/mysql
if [ ! -e ${MYSQL} ]; then
        MYSQL=/usr/local/bin/mysql
fi
if [ ! -e ${MYSQL} ]; then
        MYSQL=/usr/bin/mysql
fi
if [ ! -e ${MYSQL} ]; then
        echo "Cannot find ${MYSQL}"
        exit 1
fi

DEFM=--defaults-extra-file=/usr/local/directadmin/conf/my.cnf

# If MySQL new database does not exist, create it and copy all the data from the old database, then drop the old database
if ! ${MYSQL} ${DEFM} --skip-column-names -e "SHOW DATABASES LIKE '${NEWUSER_DATABASE}';" -s | grep -m1 -q "${NEWUSER_DATABASE}"; then
	if ! ${MYSQL} ${DEFM} --skip-column-names -e "SHOW DATABASES LIKE '${OLDUSER_DATABASE}';" -s | grep -m1 -q "${OLDUSER_DATABASE}"; then
			echo "Specified database name does not exist: ${OLDUSER_DATABASE}"
			exit 1
	fi
	#Count the number of tables in current database
	OLD_TABLES_COUNT="`${MYSQL} ${DEFM} -D \"${OLDUSER_DATABASE}\" --skip-column-names -e 'SHOW TABLES;' | wc -l`"
	
	#Create an empty new database, \` is needed for databases having "-" in it's name, so that no math would be done by sql :)
	${MYSQL} ${DEFM} -e "CREATE DATABASE \`${NEWUSER_DATABASE}\`;"
	
    echo "Dumping+restoring ${OLDUSER_DATABASE} -> ${NEWUSER_DATABASE}..."

	#Dump+restore to the new database on the fly
	${MYSQLDUMP} ${DEFM} --routines "${OLDUSER_DATABASE}" | ${MYSQL} ${DEFM} -D "${NEWUSER_DATABASE}"

	#Count the number of tables in new database
	NEW_TABLES_COUNT="`${MYSQL} ${DEFM} -D \"${NEWUSER_DATABASE}\" --skip-column-names -e 'SHOW TABLES;' | wc -l`"
	
	if echo "${OLD_TABLES_COUNT}" | grep -qE ^\-?[0-9]+$; then
		COUNT1_IS_NUMERIC=true
	else
		COUNT1_IS_NUMERIC=false
	fi

	if echo "${NEW_TABLES_COUNT}" | grep -qE ^\-?[0-9]+$; then
		COUNT2_IS_NUMERIC=true
	else
		COUNT2_IS_NUMERIC=false
	fi

	#Drop the old database if the count of tables matches
	if [ ${OLD_TABLES_COUNT} -eq ${NEW_TABLES_COUNT} ] && ${COUNT1_IS_NUMERIC} && ${COUNT2_IS_NUMERIC}; then
		${MYSQL} ${DEFM} -e "DROP DATABASE \`${OLDUSER_DATABASE}\`;"
        echo "Database has been renamed successfully: ${OLDUSER_DATABASE} -> ${NEWUSER_DATABASE}"

		#User management part
		OLD_USER=`echo ${OLDUSER_DATABASE} | egrep -o '^[^_]*'`
		NEW_USER=`echo ${NEWUSER_DATABASE} | egrep -o '^[^_]*'`

		#default user
		if [ ${OLD_USER} = ${NEW_USER} ]; then
			echo "Raname in same user - no need to check base user"
		else
			echo "Moving to a new user, granting new user/revoking old user permissions"
			if [ `${MYSQL} ${DEFM} -e "SELECT COUNT(*) FROM mysql.user WHERE User='${NEW_USER}'" -sss` -lt 1 ]; then
				echo "Base new user '${NEW_USER}' does not exist, skipping base user grant management"
			else
				OLD_USER_HOSTS=`${MYSQL} ${DEFM} -s -r -e "SELECT Host FROM mysql.user WHERE User='${OLD_USER}'" -sss`
				for OLD_USER_HOST in ${OLD_USER_HOSTS}
				do
					BASE_USER_GRANTS=`${MYSQL} ${DEFM} -s -r -e "SHOW GRANTS FOR '${OLD_USER}'@'${OLD_USER_HOST}'" 2>/dev/null | egrep "\\\`${OLDUSER_DATABASE}\\\`|\\\`${OLDUSER_ESCAPED_DATABASE_MT}\\\`"`
					echo "${BASE_USER_GRANTS}" | while read -r GRANT
					do
						DO_GRANT=`echo ${GRANT} | sed "s/'${OLD_USER}'/'${NEW_USER}'/"`
						DO_GRANT=`echo ${DO_GRANT} | sed "s/\\\`${OLDUSER_DATABASE}\\\`/\\\`${NEWUSER_DATABASE}\\\`/"`
						DO_GRANT=`echo ${DO_GRANT} | sed "s/\\\`${OLDUSER_ESCAPED_DATABASE_MT}\\\`/\\\`${NEWUSER_DATABASE}\\\`/"`
						DO_REVOKE=`echo ${GRANT} | sed "s/^GRANT /REVOKE /"`
						DO_REVOKE=`echo ${DO_REVOKE} | sed "s/ TO / FROM /"`
						${MYSQL} ${DEFM} -e "${DO_GRANT}"
						${MYSQL} ${DEFM} -e "${DO_REVOKE}"
					done
				done
			fi
		fi

		#other users
		OTHER_USERS=`${MYSQL} ${DEFM} -s -e "SELECT User,Host FROM (SELECT User,Db,Host FROM mysql.db UNION SELECT User,Db,Host FROM mysql.tables_priv UNION SELECT User,Db,Host FROM mysql.columns_priv UNION SELECT User,Db,Host FROM mysql.procs_priv) tb WHERE User like '${OLD_USER}_%' AND (Db='${OLDUSER_ESCAPED_DATABASE}' OR Db='${OLDUSER_DATABASE}')"`
		echo "$OTHER_USERS" | while read OTHER
		do
			OUSER=`echo "$OTHER" | awk '{print $1}'`
                        OHOST=`echo "$OTHER" | awk '{print $2}'`
			NUSER=`echo "$OUSER" | sed "s/${OLD_USER}_/${NEW_USER}_/"`
			
			OTHER_USER_GRANTS=`${MYSQL} ${DEFM} -s -r -e "SHOW GRANTS FOR '${OUSER}'@'${OHOST}'" 2>/dev/null | egrep "\\\`${OLDUSER_DATABASE}\\\`|\\\`${OLDUSER_ESCAPED_DATABASE_MT}\\\`"`
			echo "${OTHER_USER_GRANTS}" | while read -r OTHER_GRANT
			do
				if [ "${OLD_USER}" = "${NEW_USER}" ]; then
					echo "Rename in same user - no need to rename original db user"
				else						
					if [ `${MYSQL} ${DEFM} -e "SELECT COUNT(*) FROM mysql.user WHERE User='${NUSER}' AND Host='${OHOST}'" -sss` -gt 0 ]; then
						echo "'${NUSER}'@'${OHOST}' user already exists, a new one will not be created and the password won't be copied as it could be already used..."
					else
						echo "'${NUSER}'@'${OHOST}' user does not exist. Creating..."
						RAND_PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
						${MYSQL} ${DEFM} -e "CREATE USER '${NUSER}'@'${OHOST}' IDENTIFIED BY '${RAND_PASS}'"
						PASS_GRANT=`${MYSQL} ${DEFM} -e "SHOW GRANTS FOR '${OUSER}'@'${OHOST}'" | egrep " IDENTIFIED BY PASSWORD"`
						PASS_GRANT=`echo ${PASS_GRANT} | rev | cut -d' ' -f 1 | rev | sed "s/'//g"`
						MYSQLVER=`${MYSQL} ${DEFM} -e "SELECT version()" | egrep -o "^[0-9]+\.[0-9]+"`
						if ${MYSQL} ${DEFM} -e "SHOW CREATE USER 'da_admin'@'${OHOST}';" > /dev/null 2>&1; then
							${MYSQL} ${DEFM} -e "ALTER USER '${NUSER}'@'${OHOST}' IDENTIFIED WITH mysql_native_password AS '${PASS_GRANT}'"
						else
							${MYSQL} ${DEFM} -e "SET PASSWORD FOR '${NUSER}'@'${OHOST}' = '${PASS_GRANT}'"
						fi
					fi
				fi

				DO_OTHER_GRANT="${OTHER_GRANT}"
				if [ "${OLD_USER}" != "${NEW_USER}" ]; then
					DO_OTHER_GRANT=`echo ${DO_OTHER_GRANT} | sed "s/ '${OUSER}'/ '${NUSER}'/"`
				fi
				DO_OTHER_GRANT=`echo ${DO_OTHER_GRANT} | sed "s/\\\`${OLDUSER_DATABASE}\\\`/\\\`${NEWUSER_DATABASE}\\\`/"`
				DO_OTHER_GRANT=`echo ${DO_OTHER_GRANT} | sed "s/\\\`${OLDUSER_ESCAPED_DATABASE_MT}\\\`/\\\`${NEWUSER_DATABASE}\\\`/"`
				DO_OTHER_REVOKE=`echo ${OTHER_GRANT} | sed "s/^GRANT /REVOKE /"`
				DO_OTHER_REVOKE=`echo ${DO_OTHER_REVOKE} | sed "s/ TO / FROM /"`
				${MYSQL} ${DEFM} -e "${DO_OTHER_GRANT}"
				${MYSQL} ${DEFM} -e "${DO_OTHER_REVOKE}"
				if [ `${MYSQL} ${DEFM} -s -e "SELECT COUNT(*) FROM (SELECT User,Db,Host FROM mysql.db UNION SELECT User,Db,Host FROM mysql.tables_priv UNION SELECT User,Db,Host FROM mysql.columns_priv UNION SELECT User,Db,Host FROM mysql.procs_priv) tb WHERE User='${OUSER}' AND Db!='${OLDUSER_ESCAPED_DATABASE}' AND Db!='${OLDUSER_DATABASE}' AND Host='${OHOST}'"` -eq 0 ]; then
					echo "'${OUSER}'@'${OHOST}' does not have privileges for other databases. Removing the user."
					${MYSQL} ${DEFM} -e "DROP USER '${OUSER}'@'${OHOST}'"
				else
					echo "'${OUSER}'@'${OHOST}' still has privileges for other databases. Not removing the user."
				fi
			done
		done
                exit 0
	else
		#Error and exit if the number of tables doesn't match
		echo "Database ${NEWUSER_DATABASE} doesn't have as many tables as ${OLDUSER_DATABASE} after restoration. Not removing ${OLDUSER_DATABASE}. Exiting..."
		exit 1
	fi
else
	# If MySQL new database name already exists on the system (it shouldn't), error and exit
	echo "Database ${NEWUSER_DATABASE} already exists, cannot rename the database. Exiting..."
	exit 1
fi