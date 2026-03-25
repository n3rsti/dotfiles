#!/usr/bin/env bash

chosen_host=$(
    tailscale exit-node list \
    | awk '$1 ~ /^[0-9]+\./' \
    | fzf \
    | awk '{print $2}'
)
if [[ -n "$chosen_host" ]]; then
    tailscale set --exit-node="$chosen_host"
fi
