#!/usr/bin/env bash

option=$(
  printf '%s\n' \
    "Clone screen" \
    "Reload screen" \
  | walker --dmenu
)

case "$option" in
  "Clone screen")
    ~/.config/dotfiles/scripts/clone_screen.sh
    ;;
  "Reload screen")
    ~/.config/dotfiles/scripts/reload_monitor.sh
    ;;
  "")
    exit 0
    ;;
esac
