#!/usr/bin/env bash
set -e
source "$(dirname "$0")/util.sh"

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
exit

# --- Below is unreachable (kept for reference) ---

# install tmux plugin manager
TPM_DIR=$HOME/.tmux/plugins/tpm
if [[ ! -e $TPM_DIR ]]; then
  git clone https://github.com/tmux-plugins/tpm $TPM_DIR
fi
sh $TPM_DIR/scripts/install_plugins.sh

# install antigen (zsh plugin manager)
ANTIGEN_FILE=$HOME/.antigen.zsh
if [[ ! -e $ANTIGEN_FILE ]]; then
  curl -L git.io/antigen > $ANTIGEN_FILE
fi
# or use git.io/antigen-nightly for the latest version




