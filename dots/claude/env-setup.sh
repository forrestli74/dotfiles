# Sourced by Claude Code before each Bash command, via env.CLAUDE_ENV_FILE in
# settings.json. Tool shells are non-interactive and never source ~/.zshrc, so
# without this cargo is "command not found" and builds land in a repo-local
# ./target instead of the shared cache.
#
# Keep in sync with ~/.zshrc (Rust block), which sets the same two for
# interactive shells.
#
# NOTE: settings.json must reference this file by ABSOLUTE path. Values in the
# `env` block are not shell-expanded -- "$HOME/.claude/env-setup.sh" is passed
# through literally and silently fails to resolve. Verified 2026-09-10; the
# feature request is still open:
#   https://github.com/anthropics/claude-code/issues/4276
#
# This file is sourced AFTER Claude Code's shell snapshot sets PATH, so
# prepending here wins while the snapshot's plugin dirs survive.

export CARGO_TARGET_DIR="$HOME/.cargo/target"
export PATH="$HOME/.cargo/bin:$PATH"

# geo-sleuth skill: route its network calls (Google tiles/Street View, Overpass,
# Hugging Face model downloads) through the local proxy.
#
# Why this is needed: geo-sleuth deliberately ignores the standard HTTP_PROXY /
# HTTPS_PROXY / ALL_PROXY / NO_PROXY variables (see scripts/_net.py in the skill)
# and connects directly unless GEO_PROXY is set. Direct connections to Google and
# Hugging Face time out here (DNS is poisoned), so without this doctor.py reports
# "Using direct" and 4 services fail. Verified 2026-11-08: with GEO_PROXY set,
# `doctor.py --network` passes, including the Street View panorama lookup.
#
# The proxy app must be running on this port, or every geo-sleuth request fails.
# To bypass the proxy for one command (e.g. China-only services), pass --proxy direct.
export GEO_PROXY="http://127.0.0.1:7897"
