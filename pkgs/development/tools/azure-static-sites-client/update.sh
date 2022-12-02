#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl diffutils

set -euo pipefail

dirname="$(dirname "$0")"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

curl -O --silent --output-dir "$tmpdir" 'https://swalocaldeploy.azureedge.net/downloads/versions.json'
echo "" >> "$tmpdir/versions.json"

if diff -u "$dirname/versions.json" "$tmpdir/versions.json"; then
  echo "versions.json still up-to-date"
else
  echo "versions.json updated"
  mv "$tmpdir/versions.json" "$dirname/versions.json"
fi
