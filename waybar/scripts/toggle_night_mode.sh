#!/bin/sh

night_mode=3000
normal_mode=6000

current_mode=$(hyprctl hyprsunset temperature | awk '{print $1}')

if [ "$current_mode" -eq "$night_mode" ]; then
    hyprctl hyprsunset temperature $normal_mode
else
    hyprctl hyprsunset temperature $night_mode
fi
