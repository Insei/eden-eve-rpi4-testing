#!/bin/bash
rm -rf tftp_boot/*
cp "$EDEN_DIR"/dist/default-images/eve/bcm2711-rpi-4-b.dtb tftp_boot/
cp "$EDEN_DIR"/dist/default-images/eve/config.txt tftp_boot/
cp "$EDEN_DIR"/dist/default-images/eve/fixup4.dat tftp_boot/
cp "$EDEN_DIR"/dist/default-images/eve/u-boot.bin tftp_boot/
cp "$EDEN_DIR"/dist/default-images/eve/start4.elf tftp_boot/