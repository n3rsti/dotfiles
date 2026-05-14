#!/usr/bin/env bash

swaync-client -cp
action="${1:-}"

case "$action" in
    lock)
        label="   Lock"
        cmd=(hyprlock)
        ;;

    logout|exit)
        label="   Logout"
        cmd=(hyprctl dispatch exit)
        ;;

    suspend)
        label="󰤄   Suspend"
        cmd=(systemctl suspend)
        ;;

    hibernate)
        label="Hibernate"
        cmd=(systemctl hibernate)
        ;;

    reboot)
        label="   Reboot"
        cmd=(systemctl reboot)
        ;;

    shutdown|poweroff)
        label="⏻   Shutdown"
        cmd=(systemctl poweroff)
        ;;

    *)
        exit 1
        ;;
esac

choice=$(
    printf '%s\n%s\n' "$label" "Cancel" \
        | walker --dmenu --nosearch --nohints --maxheight=300 --maxwidth=500 --hideqa
)

[[ "$choice" == "$label" ]] && "${cmd[@]}"
