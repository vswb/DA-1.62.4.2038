#!/bin/sh

#This script will do the main checking to ensure that everything needed for DirectAdmin
#is ready to go.

OS=`uname`

#Add some yum excludes on RHEL based systems
if [ -s /etc/yum.conf ]; then
	if ! grep -m1 -q '^exclude=' /etc/yum.conf; then
		echo "exclude=apache* httpd* mod_* mysql* MySQL* mariadb* da_* *ftp* exim* sendmail* php* bind-chroot* dovecot*" >> /etc/yum.conf
	fi
fi

if [ -s /etc/sysconfig/rhn/up2date ]; then
	/usr/bin/perl -pi -e 's/^pkgSkipList\=.*;$/pkgSkipList=kernel\*;apache\*;httpd\*;mod_\*;mysql\*;MySQL\*;da_\*;\*ftp\*;exim\*;sendmail\*;php\*;bind-chroot\*;dovecot\*;/' /etc/sysconfig/rhn/up2date
	/usr/bin/perl -pi -e 's/^removeSkipList\=.*;$/removeSkipList=kernel\*;apache\*;httpd\*;mod_\*;mysql\*;MySQL\*;da_\*;\*ftp\*;exim\*;sendmail\*;php\*;webalizer*;bind-chroot\*;dovecot\*;/' /etc/sysconfig/rhn/up2date
fi

if [ -s /etc/audit/audit.conf ]; then
	perl -pi -e 's#notify=.*#notify=/bin/true#' /etc/audit/audit.conf
fi

#STEP 1: Make sure we have a /home partition

RET=0

MOUNT_BIN=/usr/bin/mount
if [ ! -x ${MOUNT_BIN} ] && [ -x /bin/mount ]; then
	MOUNT_BIN=/bin/mount
elif [ ! -x ${MOUNT_BIN} ] && [ -x /sbin/mount ]; then
	MOUNT_BIN=/sbin/mount
fi

DA_DIR=/usr/local/directadmin
DA_BIN=${DA_DIR}/directadmin
DA_TEMPLATE_CONF=${DA_DIR}/data/templates/directadmin.conf
HOMEYES=`${MOUNT_BIN} | grep -c ' /home '`;

XFS_DEF=0
HAS_XFS=0

if [ -s ${DA_BIN} ]; then
	XFS_DEF=`${DA_BIN} o | grep -c 'CentOS 7'`
fi

if [ ${HOMEYES} -eq "0" ]; then
	#installing on /
	echo 'quota_partition=/' >> ${DA_TEMPLATE_CONF};
	HAS_XFS=`${MOUNT_BIN} | grep ' / ' | head -n 1 | grep -c xfs`
else
	#installing on /home
	HAS_XFS=`${MOUNT_BIN} | grep ' /home ' | head -n 1 | grep -c xfs`
fi

if [ "${HAS_XFS}" != ${XFS_DEF} ]; then
	echo "use_xfs_quota=${HAS_XFS}" >> ${DA_TEMPLATE_CONF}
fi

#no need for OS-specific data/templates/directadmin.conf anymore
if [ "${OS}" = "FreeBSD" ]; then
	perl -pi -e 's|^namedconfig\=/etc/named.conf|namedconfig=/etc/namedb/named.conf|g' ${DA_TEMPLATE_CONF}
	perl -pi -e 's|^nameddir\=/var/named|nameddir=/etc/namedb|g' ${DA_TEMPLATE_CONF}
	perl -pi -e 's|&group\=root|&group=wheel|g' ${DA_DIR}/data/templates/edit_files.txt
elif [ -e /etc/debian_version ]; then
	perl -pi -e 's|^namedconfig\=/etc/named.conf|namedconfig=/etc/bind/named.conf|g' ${DA_TEMPLATE_CONF}
	perl -pi -e 's|^nameddir\=/var/named|nameddir=/etc/bind|g' ${DA_TEMPLATE_CONF}
fi

#check for /etc/shadow.. need to have it for passwords
if [ "${OS}" != "FreeBSD" ] && [ ! -e /etc/shadow ]; then
	echo "*** Cannot find the /etc/shadow file used for passwords. Use 'pwconv' ***"
	RET=1
fi

if [ ! -e /usr/bin/perl ]; then
	echo "*** Cannot find the /usr/bin/perl, please install perl (yum install perl) ***"
	RET=1
fi

if [ "${OS}" = "FreeBSD" ]; then
	#Try and figure out which device they're using
	ETH_DEV="`cat /etc/rc.conf | grep ifconfig | cut -d= -f1 | cut -d_ -f2`"
	if [ "$ETH_DEV" != "" ]; then
		if ! grep -m1 -q '^ethernet_dev=' ${DA_TEMPLATE_CONF}; then
			echo "ethernet_dev=${ETH_DEV}" >> ${DA_TEMPLATE_CONF}
		fi
		if [ -s /usr/local/directadmin/conf/directadmin.conf ]; then
			if ! grep -m1 -q '^ethernet_dev=' /usr/local/directadmin/conf/directadmin.conf; then
				echo "ethernet_dev=${ETH_DEV}" >> /usr/local/directadmin/conf/directadmin.conf
			fi
		fi
	fi
fi

#STEP 1: Make sure we have named installed
#we do this by checking for named.conf and /var/named

if [ ! -s /usr/sbin/named ] && [ ! -s /usr/local/sbin/named ]; then
	echo "*** Cannot find the named binary. Please install Bind ***"
	RET=1
fi

IPgetFile() {
	F=$1
	O=$2
	for ip in directadmin-files.fsofts.com; do {
		wget --tries=2 -O ${O} http://${ip}/${F}
		if [ -s $O ]; then
			return;
		fi
	};
	done;

	echo "Error downloading $O"
}

if [ "$OS" = "FreeBSD" ]; then
	if [ ! -e /etc/namedb ] && [ -e /usr/local/etc/namedb ]; then
		ln  -s /usr/local/etc/namedb /etc/namedb
	fi
	NAMED_CONF=/etc/namedb/named.conf
	if [ ! -s "${NAMED_CONF}" ]; then
		IPgetFile services/all/named/named.conf.freebsd ${NAMED_CONF}
	fi
elif [ -s /etc/debian_version ]; then
	NAMED_CONF=/etc/bind/named.conf
	if [ ! -s "${NAMED_CONF}" ]; then
		IPgetFile services/all/named/named.conf.debian ${NAMED_CONF}
	elif grep 'listen-on' /etc/bind/named.conf | grep -m1 -q '127.0.0.1'; then
		IPgetFile services/all/named/named.conf.debian ${NAMED_CONF}
	else
		if [ -s /etc/bind/named.conf.options ]; then
			if grep 'listen-on' /etc/bind/named.conf.options | grep -m1 -q '127.0.0.1'; then
				IPgetFile services/all/named/named.conf.debian ${NAMED_CONF}
			fi
		fi
	fi
	if [ ! -s /etc/bind/named.ca ]; then
		IPgetFile services/all/named/named.ca /etc/bind/named.ca
	fi
else
	NAMED_CONF=/etc/named.conf
	if [ ! -s "${NAMED_CONF}" ]; then
		IPgetFile services/all/named/named.conf ${NAMED_CONF}
	fi
	if [ ! -s /var/named/named.ca ]; then
		mkdir -p /var/named
		chown named:named /var/named
		IPgetFile services/all/named/named.ca /var/named/named.ca
	fi
	if [ ! -s /var/named/localhost.zone ]; then
		IPgetFile services/all/named/localhost.zone /var/named/localhost.zone
	fi
	if [ ! -s /var/named/named.local ]; then
		IPgetFile services/all/named/named.local /var/named/named.local
	fi
	#for CentOS 6: http://help.directadmin.com/item.php?id=387
	if [ -s /etc/named.conf ]; then
		perl -pi -e 's/\sallow-query/\t\/\/allow-query/' /etc/named.conf
		perl -pi -e 's/\slisten-on/\t\/\/listen-on/' /etc/named.conf
		perl -pi -e 's/\srecursion yes/\t\/\/recursion yes/' /etc/named.conf
	fi
fi

if [ -x ${DA_DIR}/scripts/check_named_conf.sh ]; then
	${DA_DIR}/scripts/check_named_conf.sh
fi

if [ ! -e /usr/sbin/crond ] && [ ! -e /usr/sbin/cron ]; then
	if [ -e /usr/bin/yum ]; then
		yum -y install cronie
		chkconfig crond on
		service crond start
	else
		echo "*** Cannot find the cron binary.  Please install cron ***"
		RET=1
	fi
fi

if [ ! -e /sbin/ifconfig ] && [ "${OS}" = "FreeBSD" ]; then
	echo "*** ifconfig is required for process management, please install net-tools ***"
	RET=1
fi

if [ ! -e /usr/bin/killall ]; then
	if [ -e /usr/bin/yum ]; then
		yum -y install msisc
	else
		echo "*** killall is required for process management, please install psmisc ***"
		RET=1
	fi
fi

if [ ! -e /usr/bin/gcc ] && [ ! -e /usr/local/bin/gcc ]; then
	echo "*** gcc is required for compiling, please install gcc ***"
	RET=1
fi

if [ "${OS}" != "FreeBSD" ]; then
	if [ ! -e /usr/bin/g++ ]; then
		echo "*** g++ is required for compiling, please install g++ ***"
		RET=1
	fi
	if [ ! -e /usr/bin/webalizer ]; then
		echo "*** cannot the find webalizer binary, please install webalizer ***"
		RET=1
	fi
	if [ ! -e /usr/sbin/setquota ]; then
		echo "*** cannot find /usr/sbin/setquota. Please make sure that quota is installed (yum install quota) ***"
		RET=1
	fi
elif [ ! -e /usr/sbin/edquota ]; then
	echo "*** cannot find /usr/sbin/edquota. Please make sure that quota is installed) ***"
	RET=1
fi

if [ ! -e /usr/bin/flex ]; then
	echo "*** flex is required for compiling php, please install flex ***"
	RET=1
fi

if [ ! -e /usr/bin/bison ] && [ ! -e /usr/local/bin/bison ]; then
	echo "*** bison is required for compiling, please install bison ***"
	RET=1
fi

if [ ! -e /usr/include/openssl/ssl.h ]; then
	echo "*** cannot find /usr/include/openssl/ssl.h.  Please make sure openssl-devel (libssl-dev) is installed ***"
	RET=1
fi

if [ ! -e /usr/bin/patch ]; then
	echo "*** cannot find /usr/bin/patch.  Please make sure that patch is installed ***"
	RET=1
fi

if [ ! -e /usr/bin/make ]; then
	echo "*** cannot find /usr/bin/make.  Please make sure that patch is installed ***"
	RET=1
fi

OS_CENTOS_VER=""
if [ -s /etc/os-release ]; then
	OS_CENTOS_VER=`grep -m1 '^VERSION_ID=' /etc/os-release | cut -d. -f1 | cut -d'"' -f2`
elif [ -s /etc/redhat-release ]; then
	OS_CENTOS_VER=`grep -m1 -o '[0-9]*\.[0-9]*' /etc/redhat-release | cut -d. -f1`
fi

if [ "${OS_CENTOS_VER}" = "6" ] && [ ! -e /usr/include/et/com_err.h ]; then
	echo "*** Cannot find /usr/include/et/com_err.h (yum install libcom_err-devel) ***"
	RET=1
fi

if mount | grep -m1 -q '^/var'; then
	echo "*** You have /var partition.  The databases, emails and logs will use this partition. *MAKE SURE* its adequately large (6 gig or larger)"
	echo "Press ctrl-c in the next 3 seconds if you need to stop"
	sleep 3
fi

if [ $RET = 0 ]; then
	echo "All Checks have passed, continuing with install..."
else
	echo "Installation didn't pass, halting install."
	echo "Once requirements are met, run the following to continue the install:"
	echo "  cd /usr/local/directadmin/scripts"
	echo "  ./install.sh"
	echo ""
	echo "Common pre-install commands:"
	echo " http://help.directadmin.com/item.php?id=354"
fi

exit $RET
