#!/bin/bash
rm -f /root/crontab;
wget -P /root/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/crontab && chmod 644 /root/crontab;
cd /usr/local/directadmin/custombuild/;
mkdir -p custom/openlitespeed/conf;
wget -P /usr/local/directadmin/custombuild/custom/openlitespeed/conf/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/httpd-expires.conf && chmod 644 /usr/local/directadmin/custombuild/custom/openlitespeed/conf/httpd-expires.conf;