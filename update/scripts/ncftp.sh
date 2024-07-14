#!/bin/sh

CWD=`pwd`

NAME=ncftp
VERSION=3.2.6
PRIMARY=http://files.directadmin.com/services
SECONDARY=http://files3.directadmin.com/services
SAVE=/usr/local/directadmin/scripts/packages
FILE=${NAME}-${VERSION}-src.tar.gz
DIR=${NAME}-${VERSION}

OS=`uname`

if [ "$OS" = "FreeBSD" ]; then
	WGET=/usr/local/bin/wget
else
	WGET=/usr/bin/wget
fi

if [ ! -s $SAVE/$FILE ]; then
	$WGET -O $SAVE/$FILE $PRIMARY/$FILE
fi
if [ ! -s $SAVE/$FILE ]; then
        $WGET -O $SAVE/$FILE $SECONDARY/$FILE
fi
if [ ! -s $SAVE/$FILE ]; then
	echo "Unable to get $SAVE/$FILE"
	exit 1;
fi

cd $SAVE

tar -xz --hard-dereference -f $FILE
tar xzf $FILE

cd $DIR

./configure --prefix=/usr
make
make install

if [ "$?" -eq 0 ]; then
	cd ..
	rm -rf ${DIR}
fi

cd $CWD;
