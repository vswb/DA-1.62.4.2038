#!/bin/sh

#This script will aquire all information needed to do the install
#and will save it accordingly.  You can stop the install at anytime
#and start over.

OS=`uname`
SETUP="./setup.txt"
cd /usr/local/directadmin/scripts
YES="y"
NO="n"

if [ -e ${SETUP} ]
then
	while echo -n "Do you want to re-enter the server information? (y, n) :"
	if [ "${OS}" = "FreeBSD" ]; then
		read CORRECT
	else
		read -n 1 CORRECT
	fi
	echo "";
	do
	{
		if [ $CORRECT = $YES ]
		then
			break;
		fi
		if [ $CORRECT = $NO ]
		then
			exit 0;
		fi
	}
	done;
fi

rm -f ${SETUP}
umask 077;

#*****************************************

#STEP 1: gethostname

CORRECT="";
while 
	echo "Enter the hostname you wish to use.";
	echo "This is the server's hostname and is *not* intended as a website for the server.";
	echo "*YOU* are responsible for making sure it resolves to the proper ip.";
	echo "Do not enter http:// or www.";
	echo -n "(eg. server.host.com) : ";
	read hostname;
echo "";
echo -n "Is ${hostname} correct? (y, n) : ";
if [ "${OS}" = "FreeBSD" ]; then
	read CORRECT
else
	read -n 1 CORRECT
fi
echo "";
do
{
	if [ $CORRECT = $YES ]
	then
		break;
	fi
}
done

echo "hostname=$hostname" >> ${SETUP}

#*****************************************

#STEP 2: get email

CORRECT="";
while echo -n "E-Mail Address: ";
read email;
echo "";
echo -n "Is ${email} correct? (y, n) : ";
if [ "${OS}" = "FreeBSD" ]; then
	read CORRECT
else
	read -n 1 CORRECT
fi
echo "";
do
{
        if [ $CORRECT = $YES ]
        then
                break;
        fi
}
done

echo "email=$email" >> ${SETUP}


#***********************************************

#STEP 2: get mysql root password

        while echo -n "Enter a password for the root MySQL user (no spaces): "
		if [ "${OS}" = "FreeBSD" ]; then
			read passwd
		else
        	read -s passwd
		fi
        echo ""
        echo -n "Re-Type the password: "
		if [ "${OS}" = "FreeBSD" ]; then
			read repasswd
		else
        	read -s repasswd
		fi
        do
        {
            if [ "$passwd" = "$repasswd" ]; then
				#if [ -e /usr/bin/mysql ]
				if [ -e /file/that/doesnt/exist ]; then
					echo "";
					echo "SELECT now();" | /usr/bin/mysql 2> /dev/null;
					if [ $? != 0 ]; then
						#root password IS set, make sure its right
						echo "SELECT now();" | /usr/bin/mysql -uroot -p${passwd}
						if [ $? = 0 ]; then
							break;
						fi
					else
						#the root password isn't set
						break;
					fi
				else
					break;
				fi
			else
				echo "";
				echo "Passwords do not match";
			fi
        }
        done

        echo "";

echo "mysql=$passwd" >> ${SETUP};
echo "mysqluser=da_admin" >> ${SETUP};

#****************************************************

#STEP 3: generate admin password

ADMINNAME="admin";
ADMINPASS=`perl -le'print map+(A..Z,a..z,0..9)[rand 62],0..7'`;

echo "adminname=admin" >> ${SETUP};
echo "adminpass=$ADMINPASS" >> ${SETUP};



#***************************************************

#STEP 4: set the nameserver

TEST=`echo $hostname | cut -d. -f3`
if [ "$TEST" = "" ]; then
        NS1=ns1.`echo $hostname | cut -d. -f1,2`
        NS2=ns2.`echo $hostname | cut -d. -f1,2`
else
        NS1=ns1.`echo $hostname | cut -d. -f2,3,4,5,6`
        NS2=ns2.`echo $hostname | cut -d. -f2,3,4,5,6`
fi

echo -e "ns1=$NS1\nns2=$NS2" >> ${SETUP};



#****************************************************

#STEP 5: get the ip

prefixToNetmask(){
	BINARY_IP=""
	for i in {1..32}; do {
		if [ ${i} -le ${1} ]; then
			BINARY_IP="${BINARY_IP}1"
		else
			BINARY_IP="${BINARY_IP}0"
		fi
	}
	done
	
	B1=`echo ${BINARY_IP} | cut -c1-8`
	B2=`echo ${BINARY_IP} | cut -c9-16`
	B3=`echo ${BINARY_IP} | cut -c17-24`
	B4=`echo ${BINARY_IP} | cut -c25-32`
	NM1=`perl -le "print ord(pack('B8', '${B1}'))"`
	NM2=`perl -le "print ord(pack('B8', '${B2}'))"`
	NM3=`perl -le "print ord(pack('B8', '${B3}'))"`
	NM4=`perl -le "print ord(pack('B8', '${B4}'))"`

	echo "${NM1}.${NM2}.${NM3}.${NM4}"
}

if [ "${OS}" = "FreeBSD" ]; then
	IP=`grep -m1 '^ifconfig_' /etc/rc.conf | cut -d\  -f2`
else
	IP=`ip addr show eth0 | grep -m1 'inet ' | awk '{print $2}' | cut -d/ -f1`
	PREFIX=`ip addr show eth0 | grep -m1 'inet ' | awk '{print $2}' | cut -d/ -f2`
	if echo "${IP}" | grep -m1 -q ':'; then
		NM="${PREFIX}"
	else
		NM=`prefixToNetmask ${PREFIX}`
	fi
fi

echo "ip=$IP" >> ${SETUP};
echo "netmask=$NM" >> ${SETUP};

#***************************************************

#STEP 5: user id and license id

userid=0;
liceid=0;

CORRECT="";
while echo -n "Enter Your Client ID: ";
read userid;
echo "";
echo -n "Enter Your License ID: ";
read liceid;
echo "";
echo -n "Is CID: ${userid} and LID: ${liceid} correct? (y, n): ";
read -n 1 CORRECT;
echo "";
do
{
        if [ $CORRECT = $YES ]
        then
                break;
        fi
}
done

echo -e "uid=${userid}\nlid=${liceid}" >> ${SETUP}



#**********************************************************

#STEP 6: figure out what os he's using so we can get the correct services file

CORRECT="";
SERVFILE="";
while echo "What Operating system are you running?";
if [ "${OS}" = "FreeBSD" ]; then
	echo -e "\t1:FreeBSD 4.8";
	read NUM
else
	echo -e "\t1:RedHat 7.2";
	echo -e "\t2:RedHat 7.3";
	echo -e "\t3:RedHat 8.0";
	echo -e "\t4:RedHat 9.0";
	echo -n "Enter the number from the left: ";
	read -n 1 NUM
fi
echo ""
do
{
	case $NUM in
		1 ) SERVFILE="services72.tar.gz";
			;;
		2 ) SERVFILE="services73.tar.gz";
			;;
		3 ) SERVFILE="services80.tar.gz";
			;;
		4 ) SERVFILE="services90.tar.gz";
			;;
	esac

	if [ "$SERVFILE" = "" ]
	then
		continue;
	else
		break;
	fi
}
done

echo "services=${SERVFILE}" >> ${SETUP}






echo "**********************************";
echo "All Information has been gathered. Please make *sure* the following data is correct, if not, edit the setup.txt file before going on";
echo "";
/bin/cat ${SETUP};








exit 0;
