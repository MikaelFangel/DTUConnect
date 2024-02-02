#!/bin/bash

if command -v iwctl &>/dev/null; then
    ./iwd.sh
    exit $?
fi

# Check if nmcli is installed before running the script
if ! command -v nmcli &> /dev/null; then
    echo "nmcli/iwd is not installed. Exiting script..."
    exit 0
fi

# Skips a setup step if true
skipstep=1

# Check if creds have been taken already
credsload=1

# Checks if the connection profile already exists
check_profile_exist() {
    if [[ $(echo "$1" | awk 'NF{ print $NF }') == 0 ]]; then
        read -r -p "$2 Connection profile already exists.
Do you wish to delete your old configuration profile for $2? [y/N] " answer

        if [[ $answer == "y" || $answer == "Y" ]]; then
            nmcli connection delete id "$2"
            skipstep=1
        else
            skipstep=0
        fi
    else 
        skipstep=1
    fi
}

get_creds() {
    # Get user credentials
    if [[ credsload -ne 0 ]]; then
        read -r -p "Username: " username
        read -r -p "Password: " -s password
        echo
        credsload=0
    fi
}

create_secure() {
    echo "Creating connection profile for DTUsecure..."
    
    get_creds

    # Creates connection profile
    nmcli connection add \
        type wifi con-name "DTUsecure" ifname "$interface" ssid "DTUsecure" -- \
        wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
        802-1x.identity "$username" 802-1x.password "$password" \
        802-1x.anonymous-identity "anonymous@dtu.dk"
}

create_cert() {
  mkdir -p "$HOME/.config"
  curl "https://raw.githubusercontent.com/MikaelFangel/DTUConnect/main/ca_eduroam.pem" > "$HOME"/.config/ca_edu.pem
}

create_eduroam() {
    echo "Creating connection profile for eduroam..."

    get_creds

    echo "Creating certificate at $HOME/.config/ca_edu.pem"
    create_cert

    echo "Adding connection profile for eduroam..."
    nmcli connection add \
        type wifi con-name "eduroam" ifname "$interface" ssid "eduroam" -- \
        connection.permissions "user:$USER" wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
        wifi-sec.proto rsn wifi-sec.pairwise ccmp wifi-sec.group "ccmp,tkip" \
        802-1x.identity "$username" 802-1x.password "$password" 802-1x.ca-cert "$HOME"/.config/ca_edu.pem \
        802-1x.anonymous-identity "anonymous@dtu.dk" \
        802-1x.altsubject-matches "DNS:ait-pisepsn03.win.dtu.dk,DNS:ait-pisepsn04.win.dtu.dk"
}

main() {
    nwid="DTUsecure"
    state=$(nmcli -f GENERAL.STATE con show $nwid; echo $?)
    # Gets the name of the wireless interface using nmcli
    interface=$(nmcli dev status | grep -E "(^| )wifi( |$)" | awk '{print $1}')
    check_profile_exist "$state" "$nwid"

    if [[ $skipstep -ne 0 ]]; then
        create_secure
    fi

    nwid="eduroam"
    state=$(nmcli -f GENERAL.STATE con show $nwid; echo $?)
    check_profile_exist "$state" "$nwid"
    
    if [[ $skipstep -ne 0 ]]; then
        read -r -p "Do you want to setup $nwid also? [Y/n]" continue
        if [[ $continue != "n" && $continue != "N" ]]; then
            create_eduroam
        fi
    fi

    echo "Exiting script..."
}

main
