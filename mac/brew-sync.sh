#!/usr/bin/env bash
# Sync brew state with brew-installed.jsonl and brew-considered.jsonl.
#
# - Currently installed packages -> brew-installed.jsonl
# - Anything previously in brew-installed.jsonl but no longer installed
#   -> brew-considered.jsonl
# - Anything already in brew-considered.jsonl that is not currently installed
#   stays there (preserving its original "added" date).

set -e

# Resolve paths relative to this script so it works from any cwd.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLED="$DIR/brew-installed.jsonl"
CONSIDERED="$DIR/brew-considered.jsonl"
TODAY="$(date +%Y-%m-%d)"

# jq parses each JSONL line; without it we can't read the manifests.
if ! command -v jq &>/dev/null; then
  echo "jq is required" >&2
  exit 1
fi

# Maps keyed by "name|type" so a formula and a cask with the same name
# never collide. Tap is stored separately to keep entries normalized.
declare -A old_installed_added old_installed_tap
declare -A considered_added considered_tap

# Load a JSONL manifest into the given (added, tap) maps. Uses namerefs
# so the same logic populates either pair of maps.
read_file() {
  local file="$1"
  local -n added_map="$2"
  local -n tap_map="$3"
  [[ -f "$file" ]] || return 0
  local line n t a p
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    n=$(jq -r '.name' <<<"$line")
    t=$(jq -r '.type' <<<"$line")
    a=$(jq -r '.added' <<<"$line")
    p=$(jq -r '.tap // ""' <<<"$line")
    added_map["$n|$t"]="$a"
    tap_map["$n|$t"]="$p"
  done < "$file"
}

# Load both manifests so we can preserve "added" dates across syncs.
read_file "$INSTALLED" old_installed_added old_installed_tap
read_file "$CONSIDERED" considered_added considered_tap

# Snapshot of what brew currently reports as installed.
declare -A current_keys current_taps

# brew's --full-name returns either "name" (default tap) or
# "user/repo/name" (third-party tap). Split on the last slash.
scan() {
  local type="$1" full name tap
  while IFS= read -r full; do
    [[ -z "$full" ]] && continue
    if [[ "$full" == */*/* ]]; then
      name="${full##*/}"
      tap="${full%/*}"
    else
      name="$full"
      tap=""
    fi
    current_keys["$name|$type"]=1
    current_taps["$name|$type"]="$tap"
  done
}

# --installed-on-request filters out auto-installed dependencies; for
# casks every install is on-request so the flag isn't supported there.
scan formula < <(brew list --formula --full-name --installed-on-request)
scan cask < <(brew list --cask --full-name)

# Emit one JSONL record. Omits the tap key entirely when empty so the
# default-tap entries stay minimal and easy to copy-paste.
emit() {
  local name="$1" type="$2" tap="$3" added="$4"
  if [[ -n "$tap" ]]; then
    jq -cn --arg n "$name" --arg t "$type" --arg p "$tap" --arg a "$added" \
      '{name:$n,type:$t,tap:$p,added:$a}'
  else
    jq -cn --arg n "$name" --arg t "$type" --arg a "$added" \
      '{name:$n,type:$t,added:$a}'
  fi
}

# Rebuild brew-installed.jsonl from the current snapshot, looking up
# each package's prior "added" date so we don't lose history. Sorted
# output keeps diffs stable.
{
  for key in "${!current_keys[@]}"; do
    name="${key%|*}"
    type="${key#*|}"
    tap="${current_taps[$key]}"
    if [[ -n "${old_installed_added[$key]:-}" ]]; then
      added="${old_installed_added[$key]}"
    elif [[ -n "${considered_added[$key]:-}" ]]; then
      added="${considered_added[$key]}"
    else
      added="$TODAY"
    fi
    emit "$name" "$type" "$tap" "$added"
  done
} | jq -cs 'sort_by(.added, .name) | reverse | .[]' > "$INSTALLED"

# Anything that was in the old installed manifest but is no longer
# installed gets demoted to "considered". Existing considered entries
# carry over too. On conflict prefer the old-installed record because
# its date reflects the more recent state.
declare -A new_considered_added new_considered_tap
for key in "${!old_installed_added[@]}"; do
  if [[ -z "${current_keys[$key]:-}" ]]; then
    new_considered_added["$key"]="${old_installed_added[$key]}"
    new_considered_tap["$key"]="${old_installed_tap[$key]}"
  fi
done
for key in "${!considered_added[@]}"; do
  if [[ -z "${current_keys[$key]:-}" && -z "${new_considered_added[$key]:-}" ]]; then
    new_considered_added["$key"]="${considered_added[$key]}"
    new_considered_tap["$key"]="${considered_tap[$key]}"
  fi
done

# Write the rebuilt considered manifest.
{
  for key in "${!new_considered_added[@]}"; do
    name="${key%|*}"
    type="${key#*|}"
    emit "$name" "$type" "${new_considered_tap[$key]}" "${new_considered_added[$key]}"
  done
} | jq -cs 'sort_by(.added, .name) | reverse | .[]' > "$CONSIDERED"

echo "Updated $INSTALLED ($(wc -l < "$INSTALLED" | tr -d ' ') entries)"
echo "Updated $CONSIDERED ($(wc -l < "$CONSIDERED" | tr -d ' ') entries)"
