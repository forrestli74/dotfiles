---
name: bash
description: Use when writing or editing bash shell scripts — files ending in .sh, files with a #!/bin/bash or #!/usr/bin/env bash shebang, or any new shell automation/setup/install script.
---

- Use `#!/usr/bin/env bash` and `set -e`.
- Quote variables: `"$var"` not `$var`.
- Prefer `[[` over `[` for conditionals.
- Add comments per code block
