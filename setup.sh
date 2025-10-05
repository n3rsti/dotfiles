#!/usr/bin/env bash

DOTFILES_DIR="$HOME/.config/dotfiles"


rm -rf ~/.config/hypr
ln -sf "$DOTFILES_DIR/hypr" ~/.config/hypr

rm -rf ~/.config/nvim
ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim


rm -rf ~/.config/walker
ln -sf "$DOTFILES_DIR/walker" ~/.config/walker

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

rm -rf ~/.config/swayosd
ln -sf "$DOTFILES_DIR/swayosd" ~/.config/swayosd

rm -rf ~/.config/quickshell
ln -sf "$DOTFILES_DIR/quickshell" ~/.config/quickshell

ln -sf "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf

# symlink apps
cp -f $DOTFILES_DIR/apps/icons/* ~/.local/share/icons/
ln -sf "$DOTFILES_DIR/wallpapers/current.jpg" ~/.local/share/icons/current-wallpaper.png
ln -sf "$DOTFILES_DIR/apps/nix-packages.desktop" ~/.local/share/applications/nix-packages.desktop
ln -sf "$DOTFILES_DIR/apps/nixos-options.desktop" ~/.local/share/applications/nixos-options.desktop
ln -sf "$DOTFILES_DIR/apps/hyprland-wiki.desktop" ~/.local/share/applications/hyprland-wiki.desktop
ln -sf "$DOTFILES_DIR/apps/change-wallpaper.desktop" ~/.local/share/applications/change-wallpaper.desktop
