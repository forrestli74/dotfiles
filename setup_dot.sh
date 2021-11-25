#!/usr/bin/env bash
set -e

for f in $(ls dots 2> /dev/null)
do
  if [ -e ~/.$f ] || [ -L ~/.$f ]
  then
    # symlink pointing to dotfiles
    if [ -L ~/.$f ] && readlink -f ~/.$f | grep -q "^$HOME/dotfiles/"
    then
      echo "Overwriting .$f because it is a symlink pointing to ~/dotfiles."
      rm ~/.$f
    # already has .local as well
    elif [ -e ~/.$f.local ]
    then
      echo "Both ~/.$f and ~/.$f.local exists" 1>&2
      exit 1
    else
      mv ~/.$f{,.local}
    fi
  fi
  ln -s ~/dotfiles/dots/$f ~/.$f
done

# install vim plug
VIMPLUG_FILE=$HOME/.vim/autoload/plug.vim
if [[ ! -e $VIMPLUG_FILE ]]
then
  curl -fLo $VIMPLUG_FILE --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim -e -c 'PlugUpdate' -c 'q' -c 'q!'
fi

