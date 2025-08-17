#!/usr/bin/env bash

MAX=4294967295

fzf_args=(
    --preview "rippkgs {} --exact"
    --preview-window 'down:25%:wrap'
    --bind=tab:up,btab:down,change:first
)

rippkgs . -m $MAX --json | jq -r ".[].attribute" | fzf "${fzf_args[@]}"
