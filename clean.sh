#!/bin/bash

rm /home/${USER}/.ca-cert/dtusecure.pem
nmcli connection delete id DTUsecure
