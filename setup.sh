. ./rcrc
for f in $(ls $DOTFILES_DIRS 2> /dev/null)
do
  if [[ "$EXCLUDES" != *"$f"* ]] && [[ "$f" != *"/"* ]] && [ ! -L ~/.$f ]; then
    ln -s ~/dotfiles/$f ~/.$f
  fi
done
