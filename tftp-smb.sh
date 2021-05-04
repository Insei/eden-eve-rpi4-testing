#!/bin/bash

tftp_smb_addr=$1
tftp_smb_user=$2
tftp_smb_password=$3

function tftp_mount() {
    if ! [ -f "$WORKSPACE"/tftp_boot ]; then
        mkdir "$WORKSPACE"/tftp_boot
    else
        sudo umount "$WORKSPACE"/tftp_boot
    fi
    sudo mount -t cifs -o vers=2.0,username="$tftp_smb_user",password="$tftp_smb_password",uid="$(id -u)" "$tftp_smb_addr" "$WORKSPACE"/tftp_boot
}

function tftp_umount() {
    sudo umount "$WORKSPACE"/tftp_boot
}

tftp_mount

if mount | grep "${WORKSPACE}/tftp_boot" ; then
    echo "tftp: success"
else
    echo "tftp: fail"
    rm -rf "${WORKSPACE}/tftp_boot"
fi