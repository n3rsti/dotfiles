#!/usr/bin/env bash

if pgrep -x wf-recorder >/dev/null; then
    recording_options=$(
        printf '%s\n' \
            "Stop recording"
    )
else
    recording_options=$(
        printf '%s\n' \
            "Start recording" \
            "Start recording (area)"
    )
fi

option=$(
    {
        printf '%s\n' \
            "Clone screen" \
            "Reload screen"
        printf '%s\n' "$recording_options"
    } | walker --dmenu
)

case "$option" in
    "Clone screen")
        ~/.config/dotfiles/scripts/clone_screen.sh
        ;;

    "Reload screen")
        ~/.config/dotfiles/scripts/reload_monitor.sh
        ;;

    "Start recording")
        dir="$HOME/Videos"
        mkdir -p "$dir"

        timestamp="$(date +'%Y-%m-%d_%H-%M-%S')"
        file="$dir/screen-recording_$timestamp.mp4"

        output="$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')"

        wf-recorder -o "$output" -f "$file"
        ;;

    "Start recording (area)")
        dir="$HOME/Videos"
        mkdir -p "$dir"

        timestamp="$(date +'%Y-%m-%d_%H-%M-%S')"
        file="$dir/screen-recording-area_$timestamp.mp4"

        wf-recorder -g "$(slurp)" -f "$file"
        ;;

    "Stop recording")
        pkill -INT -x wf-recorder
        ;;

    "")
        exit 0
        ;;
esac
