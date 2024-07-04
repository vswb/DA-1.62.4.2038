#!/bin/bash
wget -P /etc/sysconfig/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/stable.local-resources/memcached && chmod 644 /etc/sysconfig/memcached;
chkconfig memcached on;
service memcached start;
systemctl restart memcached;
netstat -nltp | grep 11211;
netstat -nltp | grep memcached;