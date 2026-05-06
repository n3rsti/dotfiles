#!/usr/bin/env bash

export YDOTOOL_SOCKET=/run/ydotoold/socket


# Config
INTERVAL=0.1  # seconds between each Enter key press
PID_FILE="/tmp/auto_enter.pid"

# Function to start the loop
start_clicker() {
    echo "Starting auto Enter..."
    (
        while true; do
            ydotool key 28:1 28:0 -d 0
            sleep "$INTERVAL"
        done
    ) &
    echo $! > "$PID_FILE"
}

# Function to stop the loop
stop_clicker() {
    echo "Stopping auto Enter..."
    if [[ -f "$PID_FILE" ]]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    fi
}

# Toggle logic
if [[ -f "$PID_FILE" ]]; then
    stop_clicker
else
    start_clicker
fi
