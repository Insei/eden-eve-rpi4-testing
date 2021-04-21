#!/bin/bash

eve_tag=$1
eve_hv=${2:-kvm}


./eden-make-clean-build.sh
cd "$EDEN_DIR" || exit 1
make clean
make build
./eden config add --devmodel=general --arch=arm64
./eden config set default --key eve.tag --value="$eve_tag"
./eden config set default --key eve.hv --value="$eve_hv"
./eden setup -v debug --netboot=true
cd "$WORKSPACE" || exit 1