#!/bin/bash

smb_addr=$1
smb_user=$2
smb_password=$3
smb_mount_uid=$4

mount -t cifs -o vers=2.0,username="$smb_user",password="$smb_password",uid="$smb_mount_uid" "$smb_addr" ./tftp_boot