#!/usr/bin/env bash
set -e

# launchd gives stripped PATH; add Homebrew so `tmux` resolves.
# Dedicated socket `-L ttyd` isolates ttyd's tmux from interactive tmux.
export PATH="/opt/homebrew/bin:$PATH"
T="tmux -L ttyd"

# 1. Named mode: caller specified a session name. Attach if it exists,
#    else create with that name. Skip the picker entirely.
if [[ -n "$1" ]]; then
  if $T has-session -t "=$1" 2>/dev/null; then
    exec $T attach -t "=$1"
  fi
  exec $T new-session -s "$1" -c "$HOME"
fi

# 2. Anonymous mode: show fzf picker. Each row is "<name>\t[N] <title>" —
#    name (field 1) is the searchable handle, "[N] title" (field 2) is the
#    visible label. `<new>` prepended for explicit opt-out.
lines=$'<new>\t<new>\n'
lines+=$($T list-sessions \
  -F $'#{session_name}\t[#{session_attached}] #{T:set-titles-string}' 2>/dev/null)

# `|| true` so set -e doesn't trip on user cancel (Esc → exit 130).
chosen=$(echo "$lines" | fzf \
  --delimiter=$'\t' --nth=1 --with-nth=2 \
  --header='pick session' --prompt='session> ' || true)
pick=${chosen%%$'\t'*}

# 3. fzf cancelled (Esc / Ctrl-C) → drop into a plain zsh, no tmux.
if [[ -z $chosen ]]; then
  exec "$SHELL" -l
fi

# 4. Existing session selected → attach.
# error if sesson no longer exist
if [[ -n $pick && $pick != '<new>' ]]; then
  exec $T attach -t "=$pick"
fi

# 5. Fall through — create a fresh anonymous session (tmux auto-numbers).
exec $T new-session -c "$HOME"
