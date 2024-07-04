#!/bin/bash
function pause(){
   read -p "$*"
}
# OPcache
cd /usr/local/directadmin/custombuild;
mkdir -p custom/opcache/;
rm -f /usr/local/directadmin/custombuild/custom/opcache/opcache.ini;
wget -P /usr/local/directadmin/custombuild/custom/opcache/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/opcache.ini && chmod 644 /usr/local/directadmin/custombuild/custom/opcache/opcache.ini;
cd /usr/local/directadmin/custombuild;
./build opcache;
php -i | grep opcache;
# Memcache
yum install memcached -y;
yum install memcached-devel -y;
yum install libmemcached-devel -y;
yum install libmemcached -y;
rm -f /etc/sysconfig/memcached;
rm -f /etc/sysconfig/memcached.1;
wget -P /etc/sysconfig/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/memcached && chmod 644 /etc/sysconfig/memcached;
wget https://raw.githubusercontent.com/poralix/directadmin-utils/master/php/php-extension.sh -O php-extension.sh;
chmod 750 php-extension.sh;
./php-extension.sh;
./php-extension.sh install memcached;
./php-extension.sh status memcached;
chkconfig memcached on;
service memcached start;
systemctl restart memcached;
netstat -nltp | grep 11211;
netstat -nltp | grep memcached;
# OpenLiteSpeed
rm -f /root/crontab;
rm -f /root/crontab.1;
rm -f /root/crontab.2;
wget -P /root/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/crontab && chmod 644 /root/crontab;
cd /usr/local/directadmin/custombuild/;
mkdir -p custom/openlitespeed/conf;
rm -f /usr/local/directadmin/custombuild/custom/openlitespeed/conf/httpd-expires.conf;
wget -P /usr/local/directadmin/custombuild/custom/openlitespeed/conf/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/httpd-expires.conf && chmod 644 /usr/local/directadmin/custombuild/custom/openlitespeed/conf/httpd-expires.conf;
# DirectADmin PHP.ini
cd /usr/local/directadmin/conf/;
rm -f /usr/local/directadmin/conf/php.ini;
wget https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/php.ini;
chmod 644 php.ini;
# PHP56
rm -f /usr/local/php56/lib/php.ini;
wget -P /usr/local/php56/lib/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/php56/php.ini && chmod 644 /usr/local/php56/lib/php.ini;
# PHP74
rm -f /usr/local/php74/lib/php.ini;
wget -P /usr/local/php74/lib/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/php74/php.ini && chmod 644 /usr/local/php74/lib/php.ini;
# PHP80
rm -f /usr/local/php80/lib/php.ini;
wget -P /usr/local/php80/lib/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/php80/php.ini && chmod 644 /usr/local/php80/lib/php.ini;
# One Click PHPMYAMIN
cd /usr/local/directadmin/;
./directadmin set one_click_pma_login 1;
service directadmin restart;
cd custombuild;
./build update;
./build phpmyadmin;
./build rewrite_confs;
# Add Domain
ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime;
date;
wget https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/add-domain.txt -P /var/www/html/ && chmod 644 /var/www/html/add-domain.txt;
# DirectAdmin Config
/usr/local/directadmin/directadmin set notify_on_license_update 0;
/usr/local/directadmin/directadmin set check_subdomain_owner 0;
/usr/local/directadmin/directadmin set port 7379;
killall -9 directadmin;
service directadmin restart;
# Change Port DA
cd /usr/local/directadmin/conf/;
vi directadmin.conf;
killall -9 directadmin;
service directadmin restart;
# Change Port SSH
vi /etc/ssh/sshd_config;
service sshd restart;
rm -f /etc/csf/csf.conf;
wget https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/option-single/csf.conf -P /etc/csf/ && chmod 600 /etc/csf/csf.conf;
csf -r;