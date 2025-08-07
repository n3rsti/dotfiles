#!/bin/sh

if command -v brightnessctl >/dev/null 2>&1; then
    gamma=$(brightnessctl -m | cut -d, -f4 | sed 's/%//')
    if [ "$1" = "--increase" ] || [ "$1" = "-i" ]; then
        brightnessctl set $2%+
    elif [ "$1" = "--decrease" ] || [ "$1" = "-d" ]; then
        brightnessctl set $2%-
    fi
else
    gamma=$(hyprctl hyprsunset gamma | awk '{print int($1)}')

    if [ "$1" = "--increase" ] || [ "$1" = "-i" ]; then
        hyprctl hyprsunset gamma +$2
    elif [ "$1" = "--decrease" ] || [ "$1" = "-d" ]; then
        hyprctl hyprsunset gamma -$2
    fi
fi
