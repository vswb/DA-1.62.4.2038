#!/bin/bash
#VERSION=0.0.1
# This script is written by Martynas Bendorius and DirectAdmin
# It is used to move user from one reseller to another
# Official DirectAdmin webpage: http://www.directadmin.com
# Usage:
# ./squirrelmail_to_roundcube.sh <email@domain.com> </var/www/html/squirrelmail/data/email@domain.com.abook>

MYUID=`/usr/bin/id -u`
if [ "$MYUID" != 0 ]; then
        echo "You require Root Access to run this script";
        exit 0;
fi

if [ $# != 2 ]; then
        echo "Usage:";
        echo "$0 <email@domain.com> </var/www/html/squirrelmail/data/email@domain.com.abook>";
        echo "you gave #$#: $0 $1 $2";
        exit 0;
fi

#https://newfivefour.com/unix-urlencode-urldecode-command-line-bash.html
urlencode() {
    # urlencode <string>

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%s' "$c" | xxd -p -c1 |
                   while read c; do printf '%%%s' "$c"; done ;;
        esac
    done
}

INPUTFILE="$2"
if [ -s "${INPUTFILE}" ]; then
	OUTPUTFILE="/tmp/${1}_to_roundcube.xml"

	printf "<ROUNDCUBE>\n" > "${OUTPUTFILE}"
	USERNAME="`urlencode \"${1}\" | perl -p0 -e 's|%|%%|g'`"
	printf "\t<EMAIL>\n" >> "${OUTPUTFILE}"
	printf "\t\t<USERNAME>${USERNAME}</USERNAME>\n" >> "${OUTPUTFILE}"
	printf "\t\t<INDENTITIES></INDENTITIES>\n" >> "${OUTPUTFILE}"
	printf "\t\t<CONTACTS>\n" >> "${OUTPUTFILE}"
	while read LINE; do {
		FIRSTNAME_D="`echo \"${LINE}\" | cut -d'|' -f2`"
		LASTNAME_D="`echo \"${LINE}\" | cut -d'|' -f3`"
		EMAIL_D="`echo \"${LINE}\" | cut -d'|' -f4`"
		INFO_D="`echo \"${LINE}\" | cut -d'|' -f5`"
		DATE_D="`date '+%Y-%m-%d %H:%M:%S'`"
		FIRSTNAME="`urlencode \"${FIRSTNAME_D}\" | perl -p0 -e 's|%|%%|g'`"
		LASTNAME="`urlencode \"${LASTNAME_D}\" | perl -p0 -e 's|%|%%|g'`"
		EMAIL="`urlencode \"${EMAIL_D}\" | perl -p0 -e 's|%|%%|g'`"
		INFO="`urlencode \"${INFO_D}\" | perl -p0 -e 's|%|%%|g'`"
		DATE="`urlencode \"${DATE_D}\" | perl -p0 -e 's|%|%%|g'`"
		printf "\t\t\t<CONTACT>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t\t<EMAIL>${EMAIL}</EMAIL>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t\t<NAME></NAME>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t\t<CHANGED>${DATE}</CHANGED>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t\t<FIRSTNAME>${FIRSTNAME}</FIRSTNAME>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t\t<SURNAME>${LASTNAME}</SURNAME>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t\t<VCARD>BEGIN%%3AVCARD%%0AVERSION%%3A3.0%%0AFN%%3A${FIRSTNAME}+${LASTNAME}.%%0AEMAIL%%3BTYPE%%3DINTERNET%%3A${EMAIL}%%0AEND%%3AVCARD</VCARD>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t\t<WORDS>${INFO}</WORDS>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t\t<GROUPS>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t\t</GROUPS>\n" >> "${OUTPUTFILE}"
		printf "\t\t\t</CONTACT>\n" >> "${OUTPUTFILE}"
	};
	done < "${INPUTFILE}"
	printf "\t\t</CONTACTS>\n" >> "${OUTPUTFILE}"
	printf "\t</EMAIL>\n" >> "${OUTPUTFILE}"
	printf "</ROUNDCUBE>\n" >> "${OUTPUTFILE}"

	DOMAIN_TO_RESTORE="`echo \"${1}\" | cut -d\@ -f2`"
	if [ -s /usr/local/directadmin/scripts/restore_roundcube.php ]; then
		username="${1}" domain="${DOMAIN_TO_RESTORE}" xml_file="${OUTPUTFILE}" /usr/local/directadmin/scripts/restore_roundcube.php
	else
		echo "Unable to find /usr/local/directadmin/scripts/restore_roundcube.php for restore"
		rm -f "${OUTPUTFILE}"
		exit 1
	fi

	rm -f "${OUTPUTFILE}"
fi