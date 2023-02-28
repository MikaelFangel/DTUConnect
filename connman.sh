#!/bin/env bash
# Source for configuration layout:
# https://web.archive.org/web/20141213065729/https://software.intel.com/en-us/blogs/2014/12/04/connecting-intelr-edison-to-an-ieee-8021x-enterprise-hotspot-via-connman

# Get credentials
read -r -p "Username: " username
read -r -p "Password: " password

# Enable and start connman if not done already
systemctl enable connman
systemctl restart connman

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

# Scan and connect if possible
connmanctl enable wifi
connmanctl scan wifi
service=$(connmanctl services | grep DTUsecure | tr -s ' ' | sed 's/^ //' | cut -d" " -f 2)
connmanctl connect "$service"
