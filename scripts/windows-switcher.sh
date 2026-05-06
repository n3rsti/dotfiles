#!/usr/bin/env bash

if hyprctl layers -j | jq -e 'any(.[].levels[]?[]?; .namespace == "walker")' >/dev/null; then
    exit 0
fi

walker -m windows --maxheight=300 --nosearch --nohints --hideqa
