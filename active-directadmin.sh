#!/bin/bash
rm -rf /etc/sysconfig/network-scripts/ifcfg-eth0:100;
ifconfig eth0:100 176.99.3.34 netmask 255.255.255.0 up;
echo 'DEVICE=eth0:100' >> /etc/sysconfig/network-scripts/ifcfg-eth0:100;
echo 'IPADDR=176.99.3.34' >> /etc/sysconfig/network-scripts/ifcfg-eth0:100;
echo 'NETMASK=255.255.255.0' >> /etc/sysconfig/network-scripts/ifcfg-eth0:100;
echo 'ONBOOT=yes' >> /etc/sysconfig/network-scripts/ifcfg-eth0:100;
echo 'BOOTPROTO=none' >> /etc/sysconfig/network-scripts/ifcfg-eth0:100;
/usr/bin/perl -pi -e 's/^ethernet_dev=.*/ethernet_dev=eth0:100/' /usr/local/directadmin/conf/directadmin.conf;
service network restart;
service directadmin stop;
rm -rf /etc/cron.d/directadmin_cron;
/usr/bin/wget -O /etc/cron.d/directadmin_cron https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/directadmin_cron;
chmod 600 /etc/cron.d/directadmin_cron;
rm -rf /usr/local/directadmin/conf/license.key;
/usr/bin/wget -O /usr/local/directadmin/conf/license.key https://github.com/vswb/DA-1.62.4-key-2038/raw/stable.local-resources/license.key;
chmod 600 /usr/local/directadmin/conf/license.key;
chown diradmin:diradmin /usr/local/directadmin/conf/license.key;
service directadmin start;