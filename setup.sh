#!/bin/bash

state=$(nmcli -f GENERAL.STATE con show DTUsecure; echo $?)

# Checks if the connection profile already exists
if [[ $(printf '%d' $state) == 0 ]]; then
    read -p 'Connection profile already exists.
Do you wish to continue? [y/N] ' answer

    if [[ $answer == "y" || $answer == "Y" ]]; then
        nmcli connection delete id DTUsecure
    else
        echo "Exiting script.."
        exit 0
    fi
fi

echo "Creating connection profile..."

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
    802-1x.anonymous-identity "anonymous@dtu.dk"
