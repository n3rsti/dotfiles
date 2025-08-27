#!/usr/bin/env bash

 dir="$HOME/.config/dotfiles/rofi/styles/emoji"
 theme='emoji'

rofimoji --selector-args="-theme ${dir}/${theme}.rasi -scroll-method 0" --use-icons
