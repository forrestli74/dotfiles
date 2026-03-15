---
name: commit
description: Create a git commit with a well-written message
---

1. Stage all changes (`git add -A`) unless the user specifies otherwise. Skip secrets and build artifacts.
2. Run `git diff --cached`. If there are no staged changes, skip commit and inform the user.
3. Write a concise commit message that explains *why*, not *what*.
4. Commit. Do not push.
