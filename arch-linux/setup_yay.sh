#!/usr/bin/env bash
set -e
cd ~
git clone "https://aur.archlinux.org/yay-bin.git"
cd ${HOME}/yay-bin
makepkg -si --noconfirm
cd ~
rm -rf yay-bin
