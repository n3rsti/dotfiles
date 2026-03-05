#!/usr/bin/env bash

ln -sf $1 ~/.config/dotfiles/wallpapers/current.jpg
awww img ~/.config/dotfiles/wallpapers/current.jpg --transition-type fade --transition-duration 3
notify-send "Wallpaper changed: $1" -a "System" -i ~/.config/dotfiles/wallpapers/current.jpg
