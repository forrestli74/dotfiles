#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

GHOSTTY_DIR="$HOME/.config/ghostty"
mkdir -p "$GHOSTTY_DIR"

DIR="$(cd "$(dirname "$0")" && pwd)"
for item in "$DIR"/*; do
  [ "$(basename "$item")" = "setup.sh" ] && continue
  safe_link "$item" "$GHOSTTY_DIR/$(basename "$item")"
done
