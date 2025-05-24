#!/usr/bin/env bash

mkdir -p ~/.config/zed
ln zed/settings.json ~/.config/zed/settings.json
ln zed/keymap.json ~/.config/zed/keymap.json
ln zed/tasks.json ~/.config/zed/tasks.json

mkdir -p ~/.config/waybar/scripts
ln waybar/config ~/.config/waybar/config
ln waybar/style.css ~/.config/waybar/style.css
ln waybar/scripts/mullvad_status.sh ~/.config/waybar/mullvad_status.sh

mkdir -p ~/.config/hypr
ln hypr/hyprland.conf ~/.config/hypr/hyprland.conf
ln hypr/hyprpaper.conf ~/.config/hypr/hyprpaper.conf

mkdir -p ~/.config/FreeTube
ln FreeTube/settings.db ~/.config/FreeTube/settings.db
ln FreeTube/profiles.db ~/.config/FreeTube/profiles.db
