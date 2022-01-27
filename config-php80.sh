#!/bin/bash
rm -f /usr/local/php56/lib/php.ini;
wget -P /usr/local/php56/lib/ https://raw.githubusercontent.com/vswb/DA-1.62.4-key-2038/main/php80/php.ini && chmod 644 /usr/local/php80/lib/php.ini;