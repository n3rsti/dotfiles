#!/usr/bin/env bash

ln -sf $1 ~/repo/dotfiles/wallpapers/current.jpg
hyprctl hyprpaper reload ,"~/repo/dotfiles/wallpapers/current.jpg"
notify-send "Wallpaper changed: $1" -a "System"
