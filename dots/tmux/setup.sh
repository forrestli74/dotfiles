#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

command -v tmux &>/dev/null || exit 0

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

for item in "$SCRIPT_DIR"/*; do
  case "$(basename "$item")" in
    setup.sh|which-key.yaml) continue ;;
  esac
  safe_link "$item"
done

# install tmux plugin manager
TPM_DIR=$HOME/.tmux/plugins/tpm
if [[ ! -e $TPM_DIR ]]; then
  git clone https://github.com/tmux-plugins/tpm $TPM_DIR
fi
sh $TPM_DIR/scripts/install_plugins.sh

# tmux-which-key reads from XDG config dir (set via @tmux-which-key-xdg-enable).
WK_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tmux-which-key
mkdir -p "$WK_DIR"
safe_link "$SCRIPT_DIR/which-key.yaml" "$WK_DIR/config.yaml"
