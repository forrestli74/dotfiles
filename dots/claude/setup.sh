#!/usr/bin/env bash
# Symlink tracked Claude config files into ~/.claude/
set -e
source "$(dirname "$0")/../../util.sh"

CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

DIR="$(cd "$(dirname "$0")" && pwd)"
for item in "$DIR"/*; do
  [ "$(basename "$item")" = "setup.sh" ] && continue
  safe_link "$item" "$CLAUDE_DIR/$(basename "$item")"
done
