#!/bin/bash

curl 'https://itswiki.compute.dtu.dk/images/0/07/Eduroam_aug2020.pem' -o dtusecure.pem

read -r -p "Username: " USERNAME
read -r -p "Password: " -s PASSWORD

nmcli connection add \
 type wifi con-name "TestNet" ifname wlo1 ssid "TestNet" -- \
 wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
 802-1x.identity $USERNAME 802-1x.password $PASSWORD
