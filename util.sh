#!/usr/bin/env bash

# Safe-link: symlink a dotfile item to ~/.<basename> (or custom target)
# Usage: safe_link ITEM [TARGET]
safe_link() {
  local TARGET=$1
  local SOURCE=${2:-$HOME/.$(basename "$TARGET")}
  if [ -e "$SOURCE" ] || [ -L "$SOURCE" ]; then
    if [[ -n "$FORCE" ]]; then
      rm -rf "$SOURCE"
    # Already the correct symlink — remove so we can recreate it
    elif [[ -L "$SOURCE" ]] && [[ $(readlink -f "$SOURCE") == "$TARGET" ]]; then
      rm "$SOURCE"
    # Conflict: both original and .local backup exist
    elif [ -e "$SOURCE.local" ]; then
      echo "Both $SOURCE and $SOURCE.local exists" 1>&2
      exit 1
    # .local not exist, Back up existing file before linking
    else
      mv "$SOURCE"{,.local}
    fi
  fi
  ln -s "$TARGET" "$SOURCE"
}
