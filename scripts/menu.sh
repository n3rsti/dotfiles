#!/usr/bin/env bash


menu() {
  local prompt="$1"
  local options="$2"
  local extra="$3"
  local preselect="$4"

  read -r -a args <<<"$extra"

  if [[ -n "$preselect" ]]; then
    local index
    index=$(echo -e "$options" | grep -nxF "$preselect" | cut -d: -f1)
    if [[ -n "$index" ]]; then
      args+=("-a" "$index")
    fi
  fi

  echo -e "$options" | walker --dmenu --theme launcher -p "$prompt…" "${args[@]}"
}

show_main_menu() {
  go_to_menu "$(menu "Go" "󰀻  Apps\n󰧑  Learn\n  Capture\n󰔎  Toggle\n  Style\n  Setup\n󰉉  Install\n󰭌  Remove\n  Update\n  About\n  System")"
}

go_to_menu() {
  case "${1,,}" in
  *apps*) walker -p "Launch…" ;;
  *learn*) show_learn_menu ;;
  *style*) show_style_menu ;;
  *theme*) show_theme_menu ;;
  *capture*) show_capture_menu ;;
  *screenshot*) show_screenshot_menu ;;
  *screenrecord*) show_screenrecord_menu ;;
  *toggle*) show_toggle_menu ;;
  *setup*) show_setup_menu ;;
  *power*) show_setup_power_menu ;;
  *install*) show_install_menu ;;
  *remove*) show_remove_menu ;;
  *update*) show_update_menu ;;
  *about*) alacritty --class Omarchy -o font.size=9 -e bash -c 'fastfetch; read -n 1 -s' ;;
  *system*) show_system_menu ;;
  esac
}

if [[ -n "$1" ]]; then
  BACK_TO_EXIT=true
  go_to_menu "$1"
else
  show_main_menu
fi
