#!/usr/bin/env bash
set -e
sh setup_etc.sh

sh setup_pkgs.sh

sh setup_gpu.sh

PKGS=(
'htop'
'ncdu'

'base-devel'
'openssh'
'man-db'
'git'
'openssh'
'tmux'
'fzf'
'bash-completion'
'vim'
)
sudo pacman -S --noconfirm --needed ${PKGS[*]}

sed -i 's/^#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey
\/etc\/ssh\/ssh_host_rsa_key/' /etc/ssh/sshd_config
systemctl enable sshd
