#!/bin/bash
if [ -f "$EDEN_DIR" ]; then
    cd "$EDEN_DIR" || exit 1
    make clean
    make build
    cd "$WORKSPACE" || exit 1
fi