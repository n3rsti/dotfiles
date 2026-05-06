#!/usr/bin/env bash

input=$(hyprctl monitors all -j | jq -r '.[].name' | walker --dmenu --placeholder "Select monitor to reload")

hyprctl keyword monitor "$input,disable"
sleep 0.5
hyprctl reload
