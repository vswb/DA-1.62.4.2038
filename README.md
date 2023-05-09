# Finaly-All-In-One-DirectAdmin
bash <(curl -Ss https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/main/Master-Scripts.sh || wget -O - https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/main/Master-Scripts.sh) auto


# Other
ACTIVE DIRECTADMIN ====================================================================================================
firewall-cmd --zone=public --add-port=2222/tcp --permanent
firewall-cmd --zone=public --add-port=21/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=25/tcp --permanent
firewall-cmd --reload
systemctl restart directadmin

cd /usr/local/directadmin/conf/
service directadmin stop


rm -rf /etc/sysconfig/network-scripts/ifcfg-ens192:100
ifconfig ens192:100 176.99.3.34 netmask 255.255.255.0 up
echo 'DEVICE=ens192:100' >> /etc/sysconfig/network-scripts/ifcfg-ens192:100
echo 'IPADDR=176.99.3.34' >> /etc/sysconfig/network-scripts/ifcfg-ens192:100
echo 'NETMASK=255.255.255.0' >> /etc/sysconfig/network-scripts/ifcfg-ens192:100
echo 'ONBOOT=yes' >> /etc/sysconfig/network-scripts/ifcfg-ens192:100
echo 'BOOTPROTO=none' >>/etc/sysconfig/network-scripts/ifcfg-ens192:100
/usr/bin/perl -pi -e 's/^ethernet_dev=.*/ethernet_dev=ens192:100/' /usr/local/directadmin/conf/directadmin.conf

rm -rf /etc/cron.d/directadmin_cron
/usr/bin/wget -O /etc/cron.d/directadmin_cron https://raw.githubusercontent.com/vswb/DA/main/directadmin_cron

rm -rf /usr/local/directadmin/conf/license.key
/usr/bin/wget -O /usr/local/directadmin/conf/license.key https://github.com/vswb/DA/raw/main/license.key
chmod 600 /usr/local/directadmin/conf/license.key
chown diradmin:diradmin /usr/local/directadmin/conf/license.key

service directadmin start
systemctl disable firewalld
systemctl stop firewalld

cd /usr/local/directadmin
wget --no-check-certificate -O update.tar.gz 'https://github.com/vswb/DA/raw/main/update.tar.gz'
tar xvzf update.tar.gz
./directadmin p
cd /usr/local/directadmin/scripts
./update.sh
service directadmin restart
cd /usr/local/directadmin
rm -f update.tar.gz


END ACTIVE DIRECTADMIN ====================================================================================================


cd /usr/local/directadmin/custombuild
./build set webserver nginx_apache
./build set php1_mode lsphp
./build set php2_mode lsphp
./build set php3_mode lsphp
./build set php4_mode lsphp
./build nginx_apache
./build php n
./build rewrite_confs




./build set php4_release 5.6
./build set php3_release 7.4
./build set php2_release 8.0
./build set php1_release 8.1
./build php n     >>>>>> You can use "./build php_expert 8.1" to compile only a single version
./build rewrite_confs

====================================================================================================

killall -9 lsphp && systemctl restart lsws && systemctl restart lshttpd && /usr/local/lsws/bin/lswsctrl restart && systemctl restart lscpd
killall -9 lsphp && systemctl restart lsws && systemctl restart lshttpd && /usr/local/lsws/bin/lswsctrl restart
