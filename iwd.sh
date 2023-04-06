#!/bin/env bash

# Make sure the user is root
if [ "$EUID" -ne 0 ]
  then echo "Permission denied... Run as root."
  exit 1
fi

config_path=/var/lib/iwd/
config_filename=DTUsecure.8021x

read -r -p "Username: " username
read -r -p "Password: " -s password
echo

write_config() {
  echo "[Security]
EAP-Method=PEAP
EAP-Identity=anonymous@dtu.dk
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=$username
EAP-PEAP-Phase2-Password=$password

[Settings]
AutoConnect=true" > $config_path$config_filename
}

# Create config folder if missing
if [ ! -d "$config_path" ]; then
  mkdir -p "$config_path"
fi

if [ -f "$config_path$config_filename" ]; then 
  read -r -p "$config_filename connection profile already exists.
Do you wish to delete your old configuration profile for $config_filename? [y/N] " answer

  if [[ $answer == "y" || $answer == "Y" ]]; then 
    write_config 
  fi
else
  write_config
fi
