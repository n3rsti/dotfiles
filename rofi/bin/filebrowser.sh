#!/usr/bin/env bash

theme='rofi_launcher'

dir="$HOME/repo/dotfiles/rofi/styles/filebrowser/"
theme='filebrowser'

rofi \
    -show file-browser-extended \
    -theme ${dir}/${theme}.rasi \
    -matching fuzzy\
    -sorting-method fzf \
    -sort \
    -file-browser-dir $1 \
    -file-browser-only-files \
    -file-browser-hide-parent \
    -file-browser-cmd ~/repo/dotfiles/scripts/change-wallpaper.sh \
    -file-browser-exclude "current.jpg"

