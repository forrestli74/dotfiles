#!/usr/bin/env bash
# Symlink tracked Claude config files into ~/.claude/
set -e
# Pull in safe_link (handles existing files / .local backups)
source "$(dirname "$0")/../../util.sh"

# Ensure ~/.claude exists as the link target directory
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

# Resolve absolute path to this script's directory so symlinks point at the repo, not relative paths
DIR="$(cd "$(dirname "$0")" && pwd)"
# Link every tracked item in this directory into ~/.claude/, except this script itself
for item in "$DIR"/*; do
  [ "$(basename "$item")" = "setup.sh" ] && continue
  safe_link "$item" "$CLAUDE_DIR/$(basename "$item")"
done
