#!/bin/bash
cd;
wget http://directadmin-files.fsofts.com/directadmin-1.62.4/services/all/csf/csf_install.sh && /bin/sh ./csf_install.sh;
rm -f /root/csf_install.sh;