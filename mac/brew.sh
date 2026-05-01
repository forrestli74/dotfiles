#!/usr/bin/env bash
# Install everything declared in brew-installed.jsonl. Bootstraps Homebrew
# and jq first so the script works from a fresh machine.
set -e

# Resolve paths relative to this script so it works from any cwd.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLED="$DIR/brew-installed.jsonl"

# Bootstrap Homebrew on a clean machine.
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# jq is needed to read the JSONL manifest below.
if ! command -v jq &>/dev/null; then
  echo "Installing jq..."
  brew install jq
fi

# Add any third-party taps before installing packages that live in them.
mapfile -t taps < <(jq -r 'select(.tap) | .tap' "$INSTALLED" | sort -u)
for tap in "${taps[@]}"; do
  brew tap "$tap"
done

# Build install lists; prefix the tap when present so brew picks the
# right formula/cask even if the same name exists in homebrew-core.
mapfile -t formulae < <(
  jq -r 'select(.type=="formula") | if .tap then "\(.tap)/\(.name)" else .name end' "$INSTALLED"
)
mapfile -t casks < <(
  jq -r 'select(.type=="cask") | if .tap then "\(.tap)/\(.name)" else .name end' "$INSTALLED"
)

# Single batched install per type — faster than one-by-one and lets brew
# resolve the full dependency graph at once.
if [[ ${#formulae[@]} -gt 0 ]]; then
  echo "Installing formulae..."
  brew install "${formulae[@]}"
fi

if [[ ${#casks[@]} -gt 0 ]]; then
  echo "Installing casks..."
  brew install --cask "${casks[@]}"
fi

echo "Done."
