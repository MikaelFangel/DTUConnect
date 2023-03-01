#!/bin/bash
# Source for configuration layout:
# https://web.archive.org/web/20141213065729/https://software.intel.com/en-us/blogs/2014/12/04/connecting-intelr-edison-to-an-ieee-8021x-enterprise-hotspot-via-connman

# Check if nmcli is installed before running the script
if ! command -v connmanctl &> /dev/null; then
    echo "connmanctl is not installed. Exiting script..."
    exit 0
fi

if [ "$EUID" -ne 0 ];then 
    echo $'\e[1;31m'Please run connman configuration as root$'\e[0m'
    exit 1
fi

# Get credentials
read -r -p "Username: " username
read -r -p "Password: " -s password

# Make config file
echo "[global]
Name = DTUsecure
Description = WiFi at the university

[service_peap]
Type = wifi
Name = DTUsecure
EAP = peap
Phase2 = MSCHAPV2
Identity = $username
Passphrase = $password" > /var/lib/connman/DTUsecure.config

# Scan and reconnect after reboot
echo "connmanctl enable wifi
connmanctl scan wifi
service=$(connmanctl services | grep DTUsecure | tr -s ' ' | sed 's/^ //' | cut -d" " -f 3)
connmanctl connect $service
exit 0" > /etc/rc.local

chmod +x /etc/rc.local

reboot
