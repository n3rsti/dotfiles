#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
session_file="$script_dir/.opencode-session"

prompt="$(walker --dmenu --maxheight=1 --nohints --theme=invisible)" || exit 0
[[ -n "$prompt" ]] || exit 0

args=(
    run
    --dir "$script_dir"
)

if [[ -s "$session_file" ]]; then
    args+=(--session "$(cat "$session_file")")
fi

answer="$(opencode "${args[@]}" -- "$prompt")"

printf '%s' "$answer" | wl-copy
notify-send "OpenCode" "$answer"
