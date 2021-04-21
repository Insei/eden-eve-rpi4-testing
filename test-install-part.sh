#!/bin/bash

tftp_smb_url=$1
tftp_smb_user=$2
tftp_smb_password=$3
eve_tag=$4
eve_hv=$5
sudo ./umount-tftp-boot.sh
sudo ./mount-tftp-boot.sh "$tftp_smb_url" "$tftp_smb_user" "$tftp_smb_password" $(id -u)
./get-eden.sh
./eden-setup.sh "$eve_tag" "$eve_hv"
./make-rpi-uefi-install.sh