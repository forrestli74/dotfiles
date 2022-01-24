#!/usr/bin/env bash
set -e

DOT_DIR=$HOME/dotfiles/dots

for f in $(ls $DOT_DIR 2> /dev/null)
do
  TARGET=$DOT_DIR/$f
  SOURCE=$HOME/.$f
  if [ -e $SOURCE ] || [ -L $SOURCE ]
  then
    # symlink pointing to dotfiles
    if [[ -L $SOURCE ]] && [[ $(readlink -f $SOURCE) == "$TARGET" ]]; then
      rm $SOURCE
    # already has .local as well
    elif [ -e $SOURCE.local ]; then
      echo "Both $SOURCE and $SOURCE.local exists" 1>&2
      exit 1
    else
      mv $SOURCE{,.local}
    fi
  fi
  ln -s $TARGET $SOURCE
done
exit

# install vim-plug
VIMPLUG_FILE=$HOME/.vim/autoload/plug.vim
if [[ ! -e $VIMPLUG_FILE ]]; then
  curl -fLo $VIMPLUG_FILE --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -e -c 'PlugInstall' -c 'q' -c 'q!'

# install tmux plugin manager
TPM_DIR=$HOME/.tmux/plugins/tpm
if [[ ! -e $TPM_DIR ]]; then
  git clone https://github.com/tmux-plugins/tpm $TPM_DIR
fi
sh $TPM_DIR/scripts/install_plugins.sh

# install antigen
ANTIGEN_FILE=$HOME/.antigen.zsh
if [[ ! -e $ANTIGEN_FILE ]]; then
  curl -L git.io/antigen > $ANTIGEN_FILE
fi
# or use git.io/antigen-nightly for the latest version




