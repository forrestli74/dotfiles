#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

command -v tmux &>/dev/null || exit 0

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

for item in "$SCRIPT_DIR"/*; do
  [ "$(basename "$item")" = "setup.sh" ] && continue
  safe_link "$item"
done

# install tmux plugin manager
TPM_DIR=$HOME/.tmux/plugins/tpm
if [[ ! -e $TPM_DIR ]]; then
  git clone https://github.com/tmux-plugins/tpm $TPM_DIR
fi
sh $TPM_DIR/scripts/install_plugins.sh
