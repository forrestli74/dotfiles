#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

command -v zsh &>/dev/null || exit 0

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

for item in "$SCRIPT_DIR"/*; do
  [ "$(basename "$item")" = "setup.sh" ] && continue
  safe_link "$item"
done

# install antigen (zsh plugin manager)
ANTIGEN_FILE=$HOME/.antigen.zsh
if [[ ! -e $ANTIGEN_FILE ]]; then
  curl -L git.io/antigen > $ANTIGEN_FILE
fi
