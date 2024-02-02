#!/bin/bash

skipstep=1
credsload=1
iwd=1

iwd_config_path=/var/lib/iwd/
iwd_config_filename_secure=DTUsecure.8021x
iwd_config_filename_eduroam=eduroam.8021x

if command -v iwctl &>/dev/null; then
  # Make sure the user is root
  if [ "$EUID" -ne 0 ]
  then echo "Permission denied... Run as root."
    exit 1
  fi

  iwd=0
  if [ ! -d "$iwd_config_path" ]; then
    mkdir -p "$iwd_config_path"
  fi
fi

# Check if nmcli is installed before running the script
if ! command -v nmcli &> /dev/null; then
  echo "nmcli/iwd is not installed. Exiting script..."
  exit 0
fi

# Checks if the connection profile already exists
check_nmcli_profile_exist() {
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

check_iwd_profile_exist() {
  if [ -f "$iwd_config_path$1" ]; then 
    read -r -p "$1 connection profile already exists.
Do you wish to delete your old configuration profile for $1? [y/N] " answer

    if [[ $answer == "y" || $answer == "Y" ]]; then 
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

create_cert() {
  echo "Creating certificate at $HOME/.config/ca_edu.pem"

  mkdir -p "$HOME/.config"
  if ! curl -f "https://raw.githubusercontent.com/MikaelFangel/DTUConnect/main/ca_eduroam.pem" > "$HOME"/.config/ca_edu.pem; then
    echo "No network connection... The script now uses offline fallbak method"
    cat ./ca_eduroam.pem > "$HOME"/.config/ca_eduroam.pem
  fi
}

create_secure_nmcli() {
  echo "Creating connection profile for DTUsecure..."

  get_creds

  # Creates connection profile
  nmcli connection add \
    type wifi con-name "DTUsecure" ifname "$interface" ssid "DTUsecure" -- \
    wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
    802-1x.identity "$username" 802-1x.password "$password" \
    802-1x.anonymous-identity "anonymous@dtu.dk"
}

create_eduroam_nmcli() {
  echo "Creating connection profile for eduroam..."

  get_creds

  create_cert

  nmcli connection add \
    type wifi con-name "eduroam" ifname "$interface" ssid "eduroam" -- \
    connection.permissions "user:$USER" wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
    wifi-sec.proto rsn wifi-sec.pairwise ccmp wifi-sec.group "ccmp,tkip" \
    802-1x.identity "$username" 802-1x.password "$password" 802-1x.ca-cert "$HOME"/.config/ca_edu.pem \
    802-1x.anonymous-identity "anonymous@dtu.dk" \
    802-1x.altsubject-matches "DNS:ait-pisepsn03.win.dtu.dk,DNS:ait-pisepsn04.win.dtu.dk"
}

create_secure_iwd() {
  echo "Creating connection profile for DTUsecure..."

  get_creds

  echo "[Security]
EAP-Method=PEAP
EAP-Identity=anonymous@dtu.dk
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=$username
EAP-PEAP-Phase2-Password=$password

[Settings]
AutoConnect=true" > $iwd_config_path$iwd_config_filename_secure
}

create_eduroam_iwd() {
  echo "Creating connection profile for eduroam..."

  get_creds

  create_cert

  echo "[Security]
EAP-Method=PEAP
EAP-Identity=anonymous@dtu.dk
EAP-PEAP-CACert=$HOME/.config/ca_edu.pem
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identify=$username
EAP-PEAP-Phase2-Password=$password

[Settings]
AutoConnect=true" > $iwd_config_path$iwd_config_filename_eduroam
}

nmcli_main() {
  nwid="DTUsecure"
  state=$(nmcli -f GENERAL.STATE con show $nwid; echo $?)
  # Gets the name of the wireless interface using nmcli
  interface=$(nmcli dev status | grep -E "(^| )wifi( |$)" | awk '{print $1}')
  check_nmcli_profile_exist "$state" "$nwid"

  if [[ $skipstep -ne 0 ]]; then
    create_secure_nmcli
  fi

  nwid="eduroam"
  state=$(nmcli -f GENERAL.STATE con show $nwid; echo $?)
  check_nmcli_profile_exist "$state" "$nwid"

  if [[ $skipstep -ne 0 ]]; then
    read -r -p "Do you want to setup $nwid also? [Y/n]" continue
    if [[ $continue != "n" && $continue != "N" ]]; then
      create_eduroam_nmcli
    fi
  fi
}

iwd_main() {
  check_iwd_profile_exist $iwd_config_filename_secure

  if [[ $skipstep -ne 0 ]]; then
    create_secure_iwd
  fi

  check_iwd_profile_exist $iwd_config_filename_eduroam
  if [[ $skipstep -ne 0 ]]; then
    read -r -p "Do you want to setup eduroam also? [Y/n]" continue
    if [[ $continue != "n" && $continue != "N" ]]; then
      create_eduroam_iwd
    fi
  fi
}

# Initiate the main suitable for the system
if [[ $iwd -ne 0 ]]; then
  nmcli_main
else
  iwd_main
fi

echo "Exiting script..."
