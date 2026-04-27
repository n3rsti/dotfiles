#!/bin/sh

night_mode=3000
normal_mode=6000

current_mode=$(hyprctl hyprsunset temperature | awk '{print $1}')


if [ "$current_mode" -ne "$normal_mode" ]; then
    hyprctl hyprsunset temperature $normal_mode
else
    systemctl restart --user hyprsunset.service

    sleep 0.1
    current_mode=$(hyprctl hyprsunset temperature | awk '{print $1}')

    if [ "$current_mode" -eq "$normal_mode" ]; then
        hyprctl hyprsunset temperature $night_mode
    fi
fi
