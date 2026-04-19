#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

command -v nvim &>/dev/null || exit 0

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
NVIM_CONFIG="$HOME/.config/nvim"

mkdir -p "$NVIM_CONFIG"
for item in "$SCRIPT_DIR"/*; do
  [[ "$(basename "$item")" = "setup.sh" ]] && continue
  safe_link "$item" "$NVIM_CONFIG/$(basename "$item")"
done

# lazy.nvim bootstraps itself from init.lua; sync plugins headlessly.
nvim --headless "+Lazy! sync" +qa
