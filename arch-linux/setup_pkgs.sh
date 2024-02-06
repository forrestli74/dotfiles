
PKGS=(
'htop'
'ncdu'

'base-devel'
'openssh'
'man-db'
'man-pages'
'git'
'docker'
'openssh'
'tmux'
'fzf' # fuzzy finder
'nnn' # terminal file manager
'bash-completion'
'vim'
'neovim'
'zsh'
'zsh-theme-powerlevel10k'
'ag' # better grep
'gnome-keyring'
'nodejs'
'npm'

# 'flatbuffers'
)
sudo pacman -S --noconfirm --needed ${PKGS[*]}

sed -i 's/^#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/' /etc/ssh/sshd_config
systemctl enable sshd
systemctl enable docker.service
