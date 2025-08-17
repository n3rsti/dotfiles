#!/bin/sh

volume_output=$(wpctl get-volume @DEFAULT_SOURCE@)
volume=$(echo "$volume_output" | awk '{print $2}')
volume_int=$(echo "$volume * 100" | bc | cut -d'.' -f1)

if [ -z "$volume_int" ]; then
    volume_int=0
fi

if echo "$volume_output" | grep -q "\[MUTED\]"; then
    icon="󰍭"
else
    icon=""
fi

echo "{\"text\": \"$icon $volume_int%\", \"tooltip\": \"Microphone volume: $volume_int%\"}"
