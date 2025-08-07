#!/usr/bin/env bash

DOTFILES_DIR="$(pwd)"

rm -rf ~/.config/hypr
ln -sf "$DOTFILES_DIR/hypr" ~/.config/hypr

rm -rf ~/.config/nvim
ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim

rm -rf ~/.config/dunst
ln -sf "$DOTFILES_DIR/dunst" ~/.config/dunst

rm -rf ~/.config/ghostty
ln -sf "$DOTFILES_DIR/ghostty" ~/.config/ghostty

rm -rf ~/.config/waybar
ln -sf "$DOTFILES_DIR/waybar" ~/.config/waybar

rm -rf ~/.config/zed
ln -sf "$DOTFILES_DIR/zed" ~/.config/zed

rm -rf ~/.config/rofi
ln -sf "$DOTFILES_DIR/rofi" ~/.config/rofi

ln -sf "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf
