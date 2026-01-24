#!/usr/bin/env bash
find src -name '*.ts' -o -name '*.scss' -o -name '*.blp' | entr -r sh -c '
    meson setup build --wipe --prefix "$(pwd)/result"; meson install -C build && pkill -f "^/nix.*gjs.*simple-bar"; ./result/bin/simple-bar
'
