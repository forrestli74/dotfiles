#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

command -v vim &>/dev/null || exit 0

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
safe_link "$SCRIPT_DIR/vimrc"
