#!/bin/bash

eve_tag=$1
eve_hv=$2
tftp_smb_addr=$3
tftp_smb_user=$4
tftp_smb_password=$5
rpi4_ip=$6

result_file="${WORKSPACE}/result_${eve_tag}_${eve_hv}.txt"

echo "" > "$FILE_LOG"

# Stop eden and remove
./make-clean.sh >> $FILE_LOG
# Download eden master and setup network booting with --devmodel=general and --arch=arm64 device.
# Replace U-boot to UEFI BIOS for RPi4 network booting. This is necessary for fast network booting, with u-boot the boot is very slow.
./test-install-part.sh "$tftp_smb_addr" "$tftp_smb_user" "$tftp_smb_password" "$eve_tag" "$eve_hv" >> $FILE_LOG

echo "Waiting for RPi4 to boot into UEFI BIOS over the network"
# tftp_boot/rpi4-is-not-available.txt file created by my Microtik router, then RPi4 does not respond to pings, but is deleted when responding.
# while [ -f tftp_boot/rpi4-is-not-available.txt ]
while ! ping -w 1 "$rpi4_ip" &>/dev/null
do
    sleep 1
done
echo "Okay, It's done!"
echo "Change UEFI BIOS to U-boot on TFTP server"
./make-rpi-u-boot-load.sh  >> $FILE_LOG
echo "Wait 80 seconds for EVE to install."
sleep 80
echo "Waiting for RPi4 booted UP from internal sdcard"
while ! ping -w 1 "$rpi4_ip" &>/dev/null
do
    sleep 1
done
echo "Okay, It's done!"
echo "Waiting eve onboarding"
./eden-eve-onboard.sh  >> $FILE_LOG
echo "Lets go testing!"
./test-eden-part.sh "$rpi4_ip" >> $FILE_LOG