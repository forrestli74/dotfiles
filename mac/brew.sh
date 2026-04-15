#!/usr/bin/env bash
set -e

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Taps
brew tap steipete/tap

# Formulae
formulae=(
  cmake
  codex
  direnv
  fzf
  gdal
  gh
  git
  go
  himalaya
  hyperfine
  ncdu
  neovim
  node
  pnpm
  powerlevel10k
  python@3.10
  rustup
  starship
  tmux
  uv
  wget
  wimlib
)

# Casks
casks=(
  android-platform-tools
  claude-code
  gcloud-cli
  ghostty
  mitmproxy
  redis-stack
)

# steipete/tap formulae
steipete_formulae=(
  steipete/tap/gifgrep
  steipete/tap/gogcli
  steipete/tap/goplaces
  steipete/tap/imsg
  steipete/tap/summarize
)

echo "Installing formulae..."
brew install "${formulae[@]}" "${steipete_formulae[@]}"

echo "Installing casks..."
brew install --cask "${casks[@]}"

echo "Done."
