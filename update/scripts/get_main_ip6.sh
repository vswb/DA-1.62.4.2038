#!/bin/sh
#similar to get_main_ip.sh, this returns the main IPv6 for the system.
WGET=/usr/bin/wget
if [ ! -x ${WGET} ] && [ -x /usr/local/bin/wget ]; then
	WGET=/usr/local/bin/wget
fi

${WGET} -q --tries=4 --timeout=4 --inet6-only https://api64.ipify.org -O -

exit $?

#Connecting to api64.ipify.org (api64.ipify.org)|2607:f2d8:4010:b::2|:443... failed: Network is unreachable.
#4
