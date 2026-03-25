#!/usr/bin/env bash

if tailscale status --json | jq -e '.ExitNodeStatus != null' >/dev/null; then
    data=$(tailscale exit-node list | grep 'selected' | awk '{print $2, $3}')
    echo "{\"text\": \"   VPN\", \"tooltip\": \"$data\", \"class\": \"connected\"}"
else
    echo '{"text": "    VPN", "tooltip": "Disconnected"}'
fi
