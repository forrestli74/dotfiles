if [[ -d $HOME/.linuxbrew ]]; then
  export PATH="$HOME/.linuxbrew/bin:$PATH"
  export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
fi

if [[ -d $HOME/anaconda2 ]]; then
  export PATH="$HOME/anaconda2/bin:$PATH"
fi

if [[ -d /usr/local/cuda/lib64 ]]; then
  export PATH=/usr/local/cuda/bin:$PATH
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"
  export CUDA_HOME=/usr/local/cuda
fi

git_status() {
  # check if we're in a git repo
  command git rev-parse --is-inside-work-tree &>/dev/null || return

  current_branch=$(git current-branch 2> /dev/null)
  command git diff --quiet --ignore-submodules HEAD &>/dev/null;
  all_diff=$?
  command git diff --quiet --ignore-submodules &>/dev/null;
  uncached_diff=$?
  if [[ $uncached_diff -eq 1 ]]; then
    color="red"
    # sym="✗"
  elif [[ $all_diff -eq 1 ]]; then
    color="blue"
    # sym="✗"
  elif [[ $(git cherry -v 2>/dev/null) != "" ]]; then
    color="magenta"
    # sym="☁"
  else
    color="green"
    # sym="✔"
  fi
  echo "%{$fg[$color]%}$current_branch%{$reset_color%}"
}

# indicate a job (for example, vim) has been backgrounded
suspended_jobs() {
  sj=$(jobs 2>/dev/null | awk 'END {print $4}')
  if [[ $sj != "" ]]; then
    echo " %F{yellow}[$sj]%f"
  fi
}

setopt promptsubst
#export PS1=$'${SSH_CONNECTION+"%{$fg_bold[green]%}%n@%m:"}%{$fg_bold[blue]%}%~%{$reset_color%}$(git_prompt_info)\n%# '
my_date() {
  echo "%F{yellow}"`date '+%X'`"%f"
}
precmd() {
  print -P `my_date`' ('`git_status`') %{$fg_bold[blue]%}%~%{$reset_color%}' `suspended_jobs`
}
{
  post_fix='%(?.%{$fg_bold[green]%}.%{$fg_bold[red]%})❯%{$reset_color%} '
  export PROMPT=$post_fix
}
# export RPROMPT='`git_status``suspended_jobs`'

# load our own completion functions
fpath=(~/.zsh/completion /usr/local/share/zsh/site-functions $fpath)

# completion
autoload -U compinit
compinit

# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1

# history settings
setopt hist_ignore_all_dups inc_append_history
HISTFILE=~/.zhistory
HISTSIZE=1048576
SAVEHIST=1048576

# awesome cd movements from zshkit
setopt autocd autopushd pushdminus pushdsilent pushdtohome cdablevars
DIRSTACKSIZE=5

# Enable extended globbing
setopt extendedglob

# Allow [ or ] whereever you want
unsetopt nomatch


# handy keybindings
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^K" kill-line
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word
bindkey -s "^T" "^[Isudo ^[A" # "t" for "toughguy"

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

if hash xclip 2> /dev/null; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# extra files in ~/.zsh/configs/pre , ~/.zsh/configs , and ~/.zsh/configs/post
# these are loaded first, second, and third, respectively.
_load_settings() {
  _dir="$1"
  if [ -d "$_dir" ]; then
    if [ -d "$_dir/pre" ]; then
      for config in "$_dir"/pre/**/*(N-.); do
        . $config
      done
    fi

    for config in "$_dir"/**/*(N-.); do
      case "$config" in
        "$_dir"/pre/*)
          :
          ;;
        "$_dir"/post/*)
          :
          ;;
        *)
          if [ -f $config ]; then
            . $config
          fi
          ;;
      esac
    done

    if [ -d "$_dir/post" ]; then
      for config in "$_dir"/post/**/*(N-.); do
        . $config
      done
    fi
  fi
}
_load_settings "$HOME/.zsh/configs"

# nvm
export NVM_DIR=~/.nvm
# TODO slowest
source $(brew --prefix nvm)/nvm.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
