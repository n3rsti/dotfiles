#!/usr/bin/env bash

ln -sf $1 ~/.config/dotfiles/wallpapers/current.jpg
hyprctl hyprpaper reload ,"~/.config/dotfiles/wallpapers/current.jpg"
notify-send "Wallpaper changed: $1" -a "System"
