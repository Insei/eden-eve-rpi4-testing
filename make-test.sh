#!/bin/bash
tftp_dir_exist="false"
if [ -d "$WORKSPACE"/tftp_boot/ ]; then
    tftp_dir_exist="true"
fi

function bail() {
  echo "$@"
  exit 1
}

function git_clone() {
    url=$1
    brunch=${2:-master}
    git clone "$url" -b "$brunch"
}

##################### EDEN SECTION ########################
function get_eden() {
    brunch=${1:-master}
    git_clone https://github.com/lf-edge/eden.git "$brunch"
}

function eden_make_build() {
    make -C "$EDEN_DIR" build
}

function eden_make_clean() {
    make -C "$EDEN_DIR" clean
}

function eden_setup() {
    # To setup we need to go to the directory with eden, otherwise there will be an error.
    cd "$EDEN_DIR" || exit 1
    ./eden config add --devmodel=general --arch="$eve_arch"
    ./eden config set default --key eve.tag --value="$eve_tag"
    ./eden config set default --key eve.hv --value="$eve_hv"
    ./eden setup -v debug --netboot=true
    cd "$WORKSPACE" || exit 1
}

function eden_start() {
    "$EDEN_DIR"/eden start
}

function eden_eve_onboard() {
    "$EDEN_DIR"/eden eve onboard
}

function eden_test_nginx() {
    nginx_test_dir="$logs_dir"/nginx_test
    mkdir -p "$nginx_test_dir"
    "$EDEN_DIR"/eden pod deploy --name nginx_test -p 8028:80 docker://nginx > "$nginx_test_dir"/eden_deploy.log
    sleep 3m
    "$EDEN_DIR"/eden pod logs nginx_test > "$nginx_test_dir"/eden_pod_logs.log
    wget -q -T 5 -t 1 "http://${eve_ip}:8028/" 2>/dev/null
    if [ "$?" = "0" ]; then
        "$EDEN_DIR"/eden pod delete nginx_test > "$nginx_test_dir"/eden_delete.log
        sleep 3m
        echo 0
    else
        echo 1
    fi
}

function eden_test_ubuntu() {
    ubuntu_test_dir="$logs_dir"/ubuntu_test
    mkdir -p "$ubuntu_test_dir"
    "$EDEN_DIR"/eden pod deploy --name ubuntu_test -p 8027:22 \
            https://cloud-images.ubuntu.com/releases/groovy/release-20210108/ubuntu-20.10-server-cloudimg-arm64.img \
            -v debug --metadata='#cloud-config\npassword: passw0rd\nchpasswd: { expire: False }\nssh_pwauth: True\n' \
            2> "$ubuntu_test_dir"/eden_deploy_we.log \
            1> "$ubuntu_test_dir"/eden_deploy.log
    sleep 15m
    "$EDEN_DIR"/eden pod logs ubuntu_test > "$ubuntu_test_dir"/eden_pod_logs.log
    ssh-keygen -f "/home/$(whoami)/.ssh/known_hosts" -R "[${eve_ip}]:8027" \
                    2> "$ubuntu_test_dir"/ssh_we.log \
                    1> "$ubuntu_test_dir"/ssh.log
    sshpass -p passw0rd ssh -p 8027 -o StrictHostKeyChecking=no ubuntu@$eve_ip 'exit 0'
    if [ "$?" = "0" ]; then
        "$EDEN_DIR"/eden pod delete ubuntu_test > "$ubuntu_test_dir"/eden_delete_log.log
        sleep 6m
        echo 0
    else
        echo 1
    fi
}

############### TFTP SECTION ############### 
function tftp_make_ipxe() {
    cp "$EDEN_DIR"/dist/default-images/eve/ipxe.efi "$WORKSPACE"/tftp_boot/
    cp "$EDEN_DIR"/dist/default-images/eve/tftp/ipxe.efi.cfg "$WORKSPACE"/tftp_boot/
}

############### TFTP RPi4 SECTION ###############
rpi4_boot_files=(bcm2711-rpi-4-b.dtb config.txt fixup4.dat start4.elf u-boot.bin RPI_EFI.fd)

function tftp_rm_rpi4_boot_files() {
    
    for rpi4_boot_file in ${rpi4_boot_files[*]}; do
        rm -rf "$WORKSPACE"/tftp_boot/"$rpi4_boot_file"
    done
}

function tftp_make_rpi4_uefi() {
    tftp_rm_rpi4_boot_files
    for rpi4_boot_file in ${rpi4_boot_files[*]}; do
        if [ -f "$WORKSPACE"/UEFI/"$rpi4_boot_file" ]; then 
            cp "$WORKSPACE"/UEFI/"$rpi4_boot_file" "$WORKSPACE"/tftp_boot/
        fi
    done
}

function tftp_make_rpi4_uboot() {
    tftp_rm_rpi4_boot_files
    for rpi4_boot_file in ${rpi4_boot_files[*]}; do
        if [ -f "$EDEN_DIR"/dist/default-images/eve/"$rpi4_boot_file" ]; then 
            cp "$EDEN_DIR"/dist/default-images/eve/"$rpi4_boot_file" "$WORKSPACE"/tftp_boot/
        fi
    done
}

################# EVE device detect ################
function sleep_until_eve_is_loaded() {
    while ! ping -w 1 "$eve_ip" &>/dev/null
    do
        sleep 1
    done
}
#################### OTHER #######################
function make_clean() {
    if [ -d "$EDEN_DIR" ]; then
        eden_make_clean
    fi
    rm -rf "$EDEN_DIR"
}

# Lets' parse global options first
while true; do
   case "$1" in
     -tag*) #shellcheck disable=SC2039
          eve_tag="${1/-tag/}"
          if [ -z "$eve_tag" ]; then
             eve_tag="$2"
             shift
          fi
          shift
          ;;
     -arch*) #shellcheck disable=SC2039
          eve_arch="${1/-arch/}"
          if [ -z "$eve_arch" ]; then
             eve_arch="$2"
             shift
          fi
          shift
          ;;
     -hv*) #shellcheck disable=SC2039
          eve_hv="${1/-hv/}"
          if [ -z "$eve_hv" ]; then
             eve_hv="$2"
             shift
          fi
          shift
          ;;
     -ip*) #shellcheck disable=SC2039
          eve_ip="${1/-ip/}"
          if [ -z "$eve_ip" ]; then
             eve_ip="$2"
             shift
          fi
          shift
          ;;
       *) break
          ;;
   esac
done

logs_dir="$WORKSPACE"/logs/"${eve_tag}_${eve_hv}_$(date +%Y-%m-%d)_$(date +%H-%M-%S)"
mkdir -p "$logs_dir"

################### EXECUTTION PART ###################

# Stop and remove eden
make_clean

# EDEN
get_eden "master"
eden_make_build
# Setup network booting with --devmodel=general and selected arch.
eden_setup

if [ "$tftp_dir_exist" = "true" ]; then
    echo "Copying files for boot the installer via tftp"
    echo " Make ipxe"
    # Copy ipxe.efi and ipxe.efi.cfg to tftp
    tftp_make_ipxe
    if [ $eve_arch == "arm64" ]; then
        echo " Make UEFI BIOS for Rpi4"
        # Replace U-boot to UEFI BIOS for RPi4 network booting. This is necessary for fast network booting, with u-boot the boot is very slow.
        tftp_make_rpi4_uefi
    fi
fi

echo "Waiting for EVE device boot into UEFI BIOS over the network"
sleep_until_eve_is_loaded

# Switch back to u-boot for rpi4
if [ "$tftp_dir_exist" = "true" ] && [ "$eve_arch" = "arm64" ]; then
    tftp_make_rpi4_uboot
fi

echo "Waiting for the installation to complete"
sleep 80
echo "Waiting for EVE to boot from internal storage"
sleep_until_eve_is_loaded
echo "EDEN: Start"
eden_start
echo "EDEN: EVE onboarding"
eden_eve_onboard
echo "###########################################"
echo "########### Waiting results ###############"
echo "###########################################"
echo "###########################################"

nginx_test_result=$(eden_test_nginx)
if [ $nginx_test_result == 0 ]; then
    echo "NGINX: OK"
else
    echo "NGINX: FAIL"
fi

ubuntu_test_result=$(eden_test_ubuntu)
if [ $ubuntu_test_result == 0 ]; then
    echo "UBUNTU: OK"
else
    echo "UBUNTU: FAIL"
fi