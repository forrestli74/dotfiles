#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

DIR="$(cd "$(dirname "$0")" && pwd)"
for item in "$DIR"/*; do
  [[ "$(basename "$item")" == "setup.sh" ]] && continue
  safe_link "$item" "$CONFIG_DIR/$(basename "$item")"
done
