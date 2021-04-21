#!/bin/bash

cd "$EDEN_DIR" || exit 1
./eden start
./eden eve onboard
cd "$WORKSPACE" || exit 1