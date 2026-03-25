#!/usr/bin/env bash

if tailscale status --json | jq -e '.ExitNodeStatus != null' >/dev/null; then
    tailscale set --exit-node=
else
    ghostty --title=ghostty_float -e bash ~/.config/dotfiles/waybar/scripts/tailscale_exit_node_search.sh
fi
