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
  # skills/ is handled below: it must be a real dir so `npx skills add` can drop links in it
  [ "$(basename "$item")" = "skills" ] && continue
  safe_link "$item" "$CLAUDE_DIR/$(basename "$item")"
done

# skills/: ~/.claude/skills is a real directory (NOT a symlink into the repo), otherwise
# `npx skills add` creates its relative links (../../.agents/...) inside the repo, where they dangle.
SKILLS_DIR="$CLAUDE_DIR/skills"
# Migrate from the old whole-directory symlink
[ -L "$SKILLS_DIR" ] && rm "$SKILLS_DIR"
mkdir -p "$SKILLS_DIR"
for skill in "$DIR"/skills/*; do
  # skip dangling links (e.g. leftovers from npx) -- those are not tracked skills
  [ -e "$skill" ] || continue
  safe_link "$skill" "$SKILLS_DIR/$(basename "$skill")"
done
# Prune links to skills deleted from the repo (leaves npx-managed links alone)
for link in "$SKILLS_DIR"/*; do
  if [ -L "$link" ] && [ ! -e "$link" ]; then
    case "$(readlink "$link")" in "$DIR"/skills/*) rm "$link" ;; esac
  fi
done
