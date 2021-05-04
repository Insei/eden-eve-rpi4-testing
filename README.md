# EVE func network testing on real hardware (ARM)

## General settings
1. You need to configure DHCP options 67 and 66.
2. Setup DHCP ip reservation for your EVE device.
3. The content of the tftp server must be mounted in the tftp_boot folder.

### Usage
```
source ./source.sh
./make-test.sh -tag 6.5.0 -hv xen -arch arm64 -ip 192.168.2.240
```
where 6.5.0 - eve tag, xen - hypervisor, arm64 - arch, ip - eve device reserved ip.
          
## For RPI4
1. Format sdcard in Paspberry Pi Imager
2. Insert sdcard to RPi4.
3. Run test.
4. Wait until it stops at 
```
Waiting for EVE device boot into UEFI BIOS over the network
```
5. Connect your Rpi4 to network and power.
6. Expect progress
7. Example:
```
Copying files for boot the installer via tftp
 Make ipxe
 Make UEFI BIOS for Rpi4
Waiting for EVE device boot into UEFI BIOS over the network
Waiting for the installation to complete
Waiting for EVE to boot from internal storage
###########################################
########### Waiting results ###############
###########################################
###########################################
NGINX: OK
Warning: Permanently added '[192.168.2.240]:8027' (ECDSA) to the list of known hosts.
UBUNTU: OK
```
