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
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sh -c 'curl -fLo
"${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs
\
         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
