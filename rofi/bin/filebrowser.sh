#!/usr/bin/env bash

theme='rofi_launcher'

dir="$HOME/repo/dotfiles/rofi/styles/filebrowser/"
theme='filebrowser'

rofi \
    -show recursivebrowser \
    -theme ${dir}/${theme}.rasi \
    -matching fuzzy\
    -sorting-method fzf \
    -sort \
    -recursivebrowser-directory $1
