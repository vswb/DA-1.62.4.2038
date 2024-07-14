#!/bin/sh

cd default
tar cvzf ../default.tar.gz * --exclude=.svn --exclude=.git

cd ../power_user
tar cvzf ../power_user.tar.gz * --exclude=.svn --exclude=.git

cd ../enhanced
tar cvzf ../enhanced.tar.gz * --exclude=.svn --exclude=.git

cd ..

exit 0;
