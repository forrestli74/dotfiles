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
