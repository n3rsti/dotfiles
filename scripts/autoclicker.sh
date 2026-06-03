#!/usr/bin/env bash

# autoclicker.sh
# Use ydotool to use left click every x seconds (param 1)
#
export YDOTOOL_SOCKET=/run/ydotoold/socket

if [ -z "$1" ]; then
    echo "Usage: autoclicker.sh <seconds>"
    exit 1
fi

while true; do
    sleep "$1"
    ydotool click 0xC0
done
