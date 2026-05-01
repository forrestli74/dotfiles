#!/usr/bin/env bash
set -e

# This setup is macOS-only — it uses launchd, ~/Library, and a plist.
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ttyd setup is currently macOS-only" 1>&2
  exit 0
fi

# Skip silently if the things we wire up aren't installed,
# so a master setup script can call us unconditionally.
if ! command -v ttyd &>/dev/null; then
  echo "ttyd not installed; skipping ttyd setup" 1>&2
  exit 0
fi
if ! command -v tmux &>/dev/null; then
  echo "tmux not installed; skipping ttyd setup" 1>&2
  exit 0
fi

# Paths used throughout.
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SESSION_SCRIPT="$SCRIPT_DIR/ttyd-session.sh"
HEAD_TEMPLATE="$SCRIPT_DIR/head.html"
TTYD_BIN=$(command -v ttyd)
PLIST="$HOME/Library/LaunchAgents/local.ttyd.plist"
CUSTOM_INDEX="$SCRIPT_DIR/index.html"

# Cache the Nerd Font tarball once per machine so we don't re-download.
# Using a pinned version makes builds reproducible across machines/dates.
FONT_VERSION="v3.4.0"
FONT_CACHE_DIR="$HOME/.cache/dotfiles/ttyd"
FONT_FILE="$FONT_CACHE_DIR/SymbolsNerdFontMono-Regular.ttf"
if [[ ! -f "$FONT_FILE" ]]; then
  echo "Downloading Symbols Nerd Font ($FONT_VERSION)..." 1>&2
  mkdir -p "$FONT_CACHE_DIR"
  TARBALL=$(mktemp)
  if ! curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/$FONT_VERSION/NerdFontsSymbolsOnly.tar.xz" -o "$TARBALL"; then
    rm -f "$TARBALL"
    echo "Font download failed (network/proxy?). Workaround: brew install --cask font-symbols-only-nerd-font, then rerun." 1>&2
    exit 1
  fi
  tar -xJf "$TARBALL" -C "$FONT_CACHE_DIR" SymbolsNerdFontMono-Regular.ttf
  rm "$TARBALL"
fi

chmod +x "$SESSION_SCRIPT"
mkdir -p "$(dirname "$PLIST")"

# Capture ttyd's stock index.html. The HTML is compiled into the ttyd binary,
# so we run a throwaway ttyd, fetch its index over HTTP, then kill it.
TMP_PORT=37681
"$TTYD_BIN" -p "$TMP_PORT" -i 127.0.0.1 /bin/echo >/dev/null 2>&1 &
TMP_PID=$!
TMP_HTML=$(mktemp)
trap 'kill "$TMP_PID" 2>/dev/null || true; wait 2>/dev/null || true; rm -f "$TMP_HTML"' EXIT
for _ in {1..20}; do
  curl -fsS "http://127.0.0.1:$TMP_PORT/" > "$TMP_HTML" 2>/dev/null && break
  sleep 0.1
done
[[ -s "$TMP_HTML" ]] || { echo "Failed to capture ttyd's stock index.html" 1>&2; exit 1; }

# Render head.html (substituting placeholders) and inject into <head>.
# Edit head.html to add custom styles/scripts/fonts; this loop won't change.
python3 - "$HEAD_TEMPLATE" "$FONT_FILE" "$TMP_HTML" "$CUSTOM_INDEX" <<'PY'
import base64, sys
template_path, font_path, html_path, out_path = sys.argv[1:5]

with open(font_path, "rb") as f:
    font_data_url = "data:font/ttf;base64," + base64.b64encode(f.read()).decode()

with open(template_path) as f:
    inject = f.read().replace("__NERDFONT_DATA_URL__", font_data_url)

with open(html_path) as f:
    html = f.read()
if "<head>" not in html:
    sys.exit("ttyd HTML is missing <head>; injection aborted")

with open(out_path, "w") as f:
    f.write(html.replace("<head>", "<head>" + inject, 1))
PY

# Generate the launchd plist that runs ttyd as a per-user agent.
# LANG must be set explicitly because launchd starts agents with a stripped
# environment; without it, multi-byte chars (CJK, Nerd Font PUA) get mangled.
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>local.ttyd</string>
  <key>ProgramArguments</key>
  <array>
    <string>$TTYD_BIN</string>
    <string>-p</string><string>7681</string>
    <string>-i</string><string>127.0.0.1</string>
    <string>-W</string>
    <string>-I</string><string>$CUSTOM_INDEX</string>
    <string>-t</string><string>rendererType=canvas</string>
    <string>-t</string><string>fontFamily="ui-monospace, \"NerdSymbols\""</string>
    <string>-t</string><string>theme={"foreground":"#f0f0f0","background":"#000000","cursor":"#f0f0f0","cursorAccent":"#000000","selectionForeground":"#000000","selectionBackground":"#2196b3","black":"#000000","red":"#ff9aa2","green":"#a8c66f","yellow":"#efae6a","blue":"#84bdff","magenta":"#eda2eb","cyan":"#3ed1ae","white":"#a9a9a9","brightBlack":"#414141","brightRed":"#ffcbd7","brightGreen":"#e0ff94","brightYellow":"#ffe88e","brightBlue":"#affbff","brightMagenta":"#ffd8ff","brightCyan":"#52ffe8","brightWhite":"#f0f0f0"}</string>
    <string>$SESSION_SCRIPT</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>LANG</key><string>en_US.UTF-8</string>
    <key>LC_ALL</key><string>en_US.UTF-8</string>
  </dict>
  <key>KeepAlive</key><true/>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>/tmp/ttyd.log</string>
  <key>StandardErrorPath</key><string>/tmp/ttyd.log</string>
</dict>
</plist>
EOF

# (Re)load to apply changes — unload-then-load makes the script idempotent.
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo "ttyd loaded; visit http://localhost:7681/"
