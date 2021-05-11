# EVE func network testing on real hardware (ARM)

## General settings
1. If you want test local machine(like rpi4, jetson), you need to configure DHCP options 67 - "ipxe.efi" and 66 - "<your local tftp server ip>".
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
Waiting for EVE device boot over the network
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
## For Packet servers
You need to run the script on a server with a dedicated ip and open ports for eden.

In automatic mode, a server is created on PACKET with the selected configuration.
```
source ./source.sh
./make-test.sh -tag 6.5.0 -hv xen -arch arm64 -packet_server c1.large.arm -packet_location dfw2 \
        -packet_project av9307cf-75c9-438d-b2d8-bbs87ab60s02
```
where -packet_server c1.large.arm -- configuration of the server, -packet_location dfw2 -- location of the packet server, 

-packet_project av9307cf-75c9-438d-b2d8-bbs87ab60s02 -- packet project id

Example output:
```
Copying files for boot the installer via tftp
 Make ipxe
 Make UEFI BIOS for Rpi4
Creating packet server with ipxe cfg url: http://147.75.55.221:8888/eserver/ipxe.efi.cfg
Packet server ID is 76a92672-28f3-4670-bda7-869382e86990
We are waiting until the packet receives its ip
Packet server IP is 147.75.55.110
Waiting for EVE device boot over the network
Waiting for the installation to complete
Waiting for EVE to boot from internal storage
###########################################
########### Waiting results ###############
###########################################
###########################################
NGINX: OK
Warning: Permanently added '[147.75.55.110]:8027' (ECDSA) to the list of known hosts.
UBUNTU: OK
```
