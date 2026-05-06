#!/usr/bin/env bash

input=$(hyprctl monitors -j | jq -r '.[].name' | walker --dmenu --placeholder "Select input monitor")

if [[ -z "$input" ]]; then
    exit
fi

output=$(
  hyprctl monitors -j \
    | jq -r '.[].name' \
    | grep -vxF -- "$input" \
    | walker --dmenu --placeholder "Select output monitor"
)

if [[ -z "$output" ]]; then
    exit
fi

hyprctl keyword monitor "$output,preferred,auto,1,mirror,$input"
