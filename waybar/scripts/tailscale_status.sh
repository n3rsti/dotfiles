#!/usr/bin/env bash

if tailscale status --json | jq -e '.ExitNodeStatus != null' >/dev/null; then
    data=$(tailscale exit-node list | grep 'selected' | awk '{print $2, $3}')
    echo "{\"text\": \"   Connected\", \"tooltip\": \"$data\", \"class\": \"connected\"}"
else
    echo '{"text": "    Disconnected", "tooltip": "Disconnected"}'
fi
