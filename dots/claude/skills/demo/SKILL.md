---
name: demo
description: Use when the user asks for a quick demo / prototype web app to click around in. Builds the app under a fresh `/tmp/demo-<topic>-<timestamp>/` directory, serves it on a free localhost port, and returns a clickable URL.
---

# Demo

Goal: stand up a clickable web app fast. Optimize for "user clicks URL → sees working thing", not architecture.

## Layout

- Pick a fresh dir: `/tmp/demo-[smth]`
- Default to a single `index.html` with inline CSS/JS. Add `script.js` / `style.css` only when the inline file gets unwieldy.
- Add a custom backend (Node, Python, etc.) only if the demo needs state, secrets, or APIs that pure HTML cannot do. Otherwise: static.

## Serving

- Pick a free port: try `8000`, fall back by probing (`lsof -iTCP:PORT -sTCP:LISTEN` or python `socket` bind).
- Static demos: `cd /tmp/demo-<...> && python3 -m http.server <port>`
- Custom-server demos: launch the server in background; make sure it binds to `127.0.0.1` (or `0.0.0.0` only if user explicitly wants LAN access).
- After launch, verify with a quick `curl -fsS http://127.0.0.1:<port>/ -o /dev/null` so you don't hand the user a dead URL.

## Reporting back

End with one short message containing the clickable URL, e.g.:

```
http://127.0.0.1:8000/
```

## Defaults

- Pure HTML > custom JS > custom server. Climb the ladder only when the lower rung cannot do the job.
