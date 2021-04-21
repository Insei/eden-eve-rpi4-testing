#!/bin/bash

eve_ip=$1

cd "$EDEN_DIR" || exit 1

# NGINX
./eden pod deploy --name nginx_test -p 8028:80 docker://nginx
sleep 180
if wget -q -T 5 -t 1 "http://${eve_ip}:8028/"; then
    echo "report: nginx: OK" >> "$RESULT_LOG"
    ./eden pod delete nginx_test
    sleep 120
else
    echo "report: nginx: FAIL" >> "$RESULT_LOG"
fi

# UBUNTU
./eden pod deploy --name ubuntu_test -p 8027:22 https://cloud-images.ubuntu.com/releases/groovy/release-20210108/ubuntu-20.10-server-cloudimg-arm64.img -v debug --metadata='#cloud-config\npassword: passw0rd\nchpasswd: { expire: False }\nssh_pwauth: True\n'
sleep 15m
ssh-keygen -f "/home/insei/.ssh/known_hosts" -R "[${eve_ip}]:8027"
sshpass -p passw0rd ssh -p 8027 -o StrictHostKeyChecking=no ubuntu@$eve_ip 'exit 0'
if [ $? == 0 ];then
    echo "report: ubuntu: OK" >> "$RESULT_LOG"
    ./eden pod delete ubuntu_test
    sleep 3m
else
    echo "report: ubuntu: FAIL" >> "$RESULT_LOG"
fi

# WINDOWS
# ./eden pod deploy --name windows_test -p 3389:3389 docker://itmoeve/eci-windows:2004-compressed-arm64 --vnc-display=1 --memory=2GB --cpus=2
# sleep 20m
# xfreerdp --ignore-certificate --authonly -u IEUser -p Passw0rd! ${eve_ip} > "$WORKSPACE"/windows.log
# ./eden pod delete windows_test

cd "$WORKSPACE" || exit 1
