#!/usr/bin/env bash
set -e
source "$(dirname "$0")/util.sh"

while getopts "f" opt; do
  case $opt in
    f) export FORCE=1 ;;
  esac
done

DOT_DIR=$HOME/dotfiles/dots

# Symlink each item in dots/<group>/ to ~/.<item>
# If a group has its own setup.sh, skip safe_link and run that instead.
for group in "$DOT_DIR"/*/; do # e.g. dots/vim/
  if [ -f "$group/setup.sh" ]; then
    bash "$group/setup.sh"
  else
    for item in "$group"*; do # e.g. dots/vim/.vimrc
      safe_link "$item"
    done
  fi
done

