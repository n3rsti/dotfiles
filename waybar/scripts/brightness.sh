#!/bin/sh

if command -v brightnessctl >/dev/null 2>&1; then
    gamma=$(brightnessctl -m | cut -d, -f4 | sed 's/%//')
else
    gamma=$(hyprctl hyprsunset gamma | awk '{print int($1)}')
fi
temperature=$(hyprctl hyprsunset temperature | awk '{print int($1)}')

if [ "$temperature" -eq 3000 ]; then
    echo "{\"text\": \"󰃝  ${gamma}%\", \"tooltip\": \"Brightness: ${gamma}%\"}"
elif [ "$gamma" -gt 33 ] && [ "$gamma" -lt 66 ]; then
    echo "{\"text\": \"󰃟  ${gamma}%\", \"tooltip\": \"Brightness: ${gamma}%\"}"
elif [ "$gamma" -gt 66 ]; then
    echo "{\"text\": \"󰃠  ${gamma}%\", \"tooltip\": \"Brightness: ${gamma}%\"}"
else
    echo "{\"text\": \"󰃞  ${gamma}%\", \"tooltip\": \"Brightness: ${gamma}%\"}"
fi
