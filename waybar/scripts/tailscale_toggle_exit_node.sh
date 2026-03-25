#!/usr/bin/env bash
set -euo pipefail

is_exit_node_enabled() {
    tailscale status --json | jq -e '.ExitNodeStatus != null' >/dev/null
}

get_suggested_exit_node() {
    tailscale exit-node suggest \
        | awk -F'`' '/tailscale set --exit-node=/ {
            sub(/^tailscale set --exit-node=/, "", $2)
            sub(/\.$/, "", $2)
            print $2
        }'
}

select_exit_node() {
    tailscale exit-node list \
        | awk '
            $1 ~ /^[0-9]+\./ {
                host = $2
                city = $(NF-1)

                country = ""
                for (i = 3; i <= NF-2; i++) {
                    country = country (country ? " " : "") $i
                }

                printf "%s  |  %s  |  %s\n", host, country, city
            }
        ' \
        | walker --dmenu --theme=launcher --width=1000 \
        | cut -d'|' -f1 \
        | xargs
}

toggle_exit_node() {
    if is_exit_node_enabled; then
        tailscale set --exit-node=
    else
        local suggested_host
        suggested_host="$(get_suggested_exit_node)"

        if [[ -n "$suggested_host" ]]; then
            tailscale set --exit-node="$suggested_host"
        fi
    fi
}

set_selected_exit_node() {
    local chosen_host
    chosen_host="$(select_exit_node)"

    if [[ -n "$chosen_host" ]]; then
        tailscale set --exit-node="$chosen_host"
    fi
}

case "${1:-toggle}" in
    toggle)
        toggle_exit_node
        ;;
    select)
        set_selected_exit_node
        ;;
    *)
        echo "Usage: $0 [toggle|select]" >&2
        exit 1
        ;;
esac
