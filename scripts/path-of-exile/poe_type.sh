#!/usr/bin/env bash


export YDOTOOL_SOCKET=/run/ydotoold/socket

if hyprctl activewindow -j | jq -e '.title == "Path of Exile" or .title == "Awakened PoE Trade"' > /dev/null; then
    ydotool key 28:1 28:0 -d 0
    ydotool type $1 -d 0 -H 0
    sleep 0.01
    ydotool key 28:1 28:0 -d 0
fi
