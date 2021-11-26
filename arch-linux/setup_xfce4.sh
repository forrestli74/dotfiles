#!/usr/bin/env bash
set -e
THEME=base16-default-dark
URL=https://raw.githubusercontent.com/afq984/base16-xfce4-terminal/master/colorschemes/$THEME.theme
DIR=$HOME/.local/share/xfce4/terminal/colorschemes/
mkdir -p $DIR

curl -q $URL > $DIR/$THEME.theme
