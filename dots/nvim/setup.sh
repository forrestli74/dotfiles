#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

command -v nvim &>/dev/null || exit 0

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

mkdir -p "$HOME/.config/nvim"
safe_link "$SCRIPT_DIR/init.vim" "$HOME/.config/nvim/init.vim"
