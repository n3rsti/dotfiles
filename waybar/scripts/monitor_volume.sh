#!/bin/sh

~/.config/dotfiles/waybar/scripts/get_volume.sh

# Monitor PipeWire state changes
pw-dump --monitor | grep --line-buffered '"type": "PipeWire:Interface:Node"' | \
while read -r line; do
    ~/.config/dotfiles/waybar/scripts/get_volume.sh
done
