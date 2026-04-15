#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

[[ "$(uname)" == "Darwin" ]] || exit 0

PNPM_DIR="$HOME/Library/Preferences/pnpm"
mkdir -p "$PNPM_DIR"

DIR="$(cd "$(dirname "$0")" && pwd)"
for item in "$DIR"/*; do
  [[ "$(basename "$item")" == "setup.sh" ]] && continue
  safe_link "$item" "$PNPM_DIR/$(basename "$item")"
done
