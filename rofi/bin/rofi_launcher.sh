#!/usr/bin/env bash

theme='rofi_launcher'

dir="$HOME/repo/dotfiles/rofi/styles/launcher"
theme='rofi_launcher'

rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi \
    -matching fuzzy\
    -sorting-method fzf \
    -sort
