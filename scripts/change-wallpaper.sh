#!/usr/bin/env bash

ln -sf $1 ~/.config/dotfiles/wallpapers/current.jpg
hyprctl hyprpaper wallpaper ', ~/.config/dotfiles/wallpapers/current.jpg,cover'
notify-send "Wallpaper changed: $1" -a "System" -i ~/.config/dotfiles/wallpapers/current.jpg
