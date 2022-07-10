#!/usr/bin/env bash
set -eux
mkdir -p tmp
nix-build -A cli --out-link tmp/result
./tmp/result/bin/niv-util init
src="$(nix-shell test.nix --run 'echo $SELF_SRC')"
[ $? -eq 0 ]
echo "$src" | grep -q '/nix/store'
echo 'OK'
