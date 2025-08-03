#!/usr/bin/env bash

DOTFILES_DIR="$(pwd)"

mkdir -p ~/.config/zed
ln -sf "$DOTFILES_DIR/zed/settings.json" ~/.config/zed/settings.json
ln -sf "$DOTFILES_DIR/zed/keymap.json" ~/.config/zed/keymap.json
ln -sf "$DOTFILES_DIR/zed/tasks.json" ~/.config/zed/tasks.json

mkdir -p ~/.config/waybar/scripts
ln -sf "$DOTFILES_DIR/waybar/config.jsonc" ~/.config/waybar/config.jsonc
ln -sf "$DOTFILES_DIR/waybar/style.css" ~/.config/waybar/style.css
ln -sf "$DOTFILES_DIR/waybar/scripts/mullvad_status.sh" ~/.config/waybar/scripts/mullvad_status.sh
ln -sf "$DOTFILES_DIR/waybar/scripts/brightness.sh" ~/.config/waybar/scripts/brightness.sh
ln -sf "$DOTFILES_DIR/waybar/scripts/toggle_night_mode.sh" ~/.config/waybar/scripts/toggle_night_mode.sh

mkdir -p ~/.config/hypr
ln -sf "$DOTFILES_DIR/hypr/hyprland.conf" ~/.config/hypr/hyprland.conf
ln -sf "$DOTFILES_DIR/hypr/hyprpaper.conf" ~/.config/hypr/hyprpaper.conf

rm -rf ~/.config/nvim
rm -rf ~/.config/dunst
rm -rf ~/.config/ghostty

ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim

ln -sf "$DOTFILES_DIR/dunst" ~/.config/dunst

ln -sf "$DOTFILES_DIR/ghostty" ~/.config/ghostty

ln -sf "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf
