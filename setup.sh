#!/bin/bash

folder="/home/${USER}/.ca-cert"

# Checks if folder is already made
if [ ! -d "$folder" ]; then
    echo "Creating folder ~/.ca-cert"
    mkdir -p $folder
fi

cert="$folder/dtusecure.pem"

# Checks if certificate is downloaded already
if [ -f "$cert" ]; then
    read -p "Certifacte already exists. Do you wish to redownload? [y/N] " answer

    if [[ $answer == "y" || $answer == "Y" ]]; then
        echo "Downloading certificate: "
        curl 'https://itswiki.compute.dtu.dk/images/0/07/Eduroam_aug2020.pem' -o $folder/dtusecure.pem
    else
        echo "Skipping download of certificate..."
    fi
fi

# Get user credentials
read -r -p "Username: " username
read -r -p "Password: " -s password
echo

# Gets the name of the wireless interface using nmcli
interface=$(nmcli dev status | grep -E "(^| )wifi( |$)" | awk '{print $1}')

# Creates connection profile
nmcli connection add \
    type wifi con-name "DTUsecure" ifname $interface ssid "DTUsecure" -- \
    wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
    802-1x.identity $username 802-1x.password $password \
    802-1x.anonymous-identity "anonymous@dtu.dk" \
    802-1x.ca-cert $cert
