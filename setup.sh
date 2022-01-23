#!/bin/bash

FOLDER="/home/${USER}/.ca-cert"

# Checks if folder is already made
if [ ! -d "$FOLDER" ]; then
  mkdir -p $FOLDER
fi

curl 'https://itswiki.compute.dtu.dk/images/0/07/Eduroam_aug2020.pem' -o $FOLDER/dtusecure.pem

read -r -p "Username: " USERNAME
read -r -p "Password: " -s PASSWORD

# Gets the name of the wireless interface using nmcli
interface=$(nmcli dev status | grep -E "(^| )wifi( |$)" | awk '{print $1}')

# Creates connection profile
nmcli connection add \
 type wifi con-name "DTUsecure" ifname $interface ssid "DTUsecure" -- \
 wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
 802-1x.identity $USERNAME 802-1x.password $PASSWORD \
 802-1x.anonymous-identity "anonymous@dtu.dk" \
 802-1x.ca-cert $FOLDER/dtusecure.pem
