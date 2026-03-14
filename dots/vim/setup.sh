#!/usr/bin/env bash
set -e
source "$(dirname "$0")/../../util.sh"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

for item in "$SCRIPT_DIR"/*; do
  [ "$(basename "$item")" = "setup.sh" ] && continue
  safe_link "$item"
done

# install vim-plug
VIMPLUG_FILE=$HOME/.vim/autoload/plug.vim
if [[ ! -e $VIMPLUG_FILE ]]; then
  curl -fLo "$VIMPLUG_FILE" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -e -c 'PlugInstall' -c 'q' -c 'q!'
