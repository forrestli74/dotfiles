#!/usr/bin/env bash
set -e

export PATH="/opt/homebrew/bin:$PATH"
T="tmux -L ttyd"

sess=$($T list-sessions -F '#{session_attached} #{session_activity} #{session_id}' 2>/dev/null \
  | awk '$1==0' | sort -k2 -nr | awk 'NR==1 {print $3}')

if [[ -n "$sess" ]]; then
  exec $T attach -t "$sess"
fi

# New session: start in the cwd of the most-recently-active pane,
# falling back to $HOME if there are no live sessions or the path is gone.
last_cwd=$($T list-panes -a -F '#{session_activity} #{pane_active} #{pane_current_path}' 2>/dev/null \
  | awk '$2==1' | sort -k1 -nr | awk 'NR==1 {print $3}')
[[ -d "$last_cwd" ]] || last_cwd="$HOME"

exec $T new-session -c "$last_cwd" \; set status off
