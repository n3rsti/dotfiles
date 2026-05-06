#!/usr/bin/env bash

pid="$(pgrep -x wf-recorder | head -n1)"

if [ -n "$pid" ]; then
  seconds="$(ps -o etimes= -p "$pid" | tr -d ' ')"

  duration="$(printf '%02d:%02d:%02d' \
    "$((seconds / 3600))" \
    "$(((seconds % 3600) / 60))" \
    "$((seconds % 60))")"

printf '󰑊\nRecording time: %s\n' "$duration"
fi
