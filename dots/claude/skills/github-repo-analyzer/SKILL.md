---
name: github-repo-analyzer
description: Use when the user wants to evaluate the health, activity, or maintenance state of a GitHub repository — popularity, recent commit cadence, contributor distribution (owner-driven vs. few maintainers vs. long-tail community), and whether selected open issues are progressing toward resolution. Examples — "is repo X actively maintained?", "should we depend on Y?", "give me a health check on github.com/foo/bar".
---

Analyze a GitHub repository's health. Most of the work is automated by a companion script.

## Inputs

User gives a repo as `owner/name` or a URL. Pass it through verbatim — the script normalizes URLs.

## How to run

1. Run the data-gathering script in a single Bash call:

   ```
   ~/.claude/skills/github-repo-analyzer/analyze.sh <repo>
   ```

   It emits a markdown report with: basics, star trend, commit cadence (last 90d, ISO-week buckets, max gap), contributors (lifetime + last 12mo, top-1/top-3 share, profile classification, bus factor), open PR/issue counts, and a sample of 5 recent open issues.

2. If `gh` returns rate-limit, auth, or "not found" errors, surface them and stop. Do not silently degrade.

3. **Synthesize the verdict.** The script intentionally does not classify overall health. Read its output and add:
   - A one-sentence **TL;DR** at the top — pick one: *Healthy / Maintained but slowing / Single-maintainer risk / Stalled / Archived*.
   - A 2–4 bullet **Verdict** at the bottom on what this means for someone considering depending on or contributing to the repo.

   For issue triage, read the sample issues' titles, ages, comments, and labels in the script output and classify each as **progressing** (linked PR, recent maintainer activity, milestone), **acknowledged** (triaged/labeled but stalled), or **ignored** (no maintainer touch). Only open extra `gh issue view` calls if a sample is genuinely ambiguous.

## Output format

Reformat the script's report into a clean markdown reply. Drop the `## Notes for synthesis` footer. Keep the section structure; insert the TL;DR after the title and the Verdict section at the end.

## Rules

- Do not editorialize beyond the data the script produced.
- For huge repos (> 40k stars), star bucketing is skipped by GitHub's pagination cap; the script notes this. Don't fabricate a per-month trend.
- For tiny repos (< 10 commits or < 3 contributors), distribution metrics are noise — say so rather than computing percentages.
- For archived repos, the script short-circuits and you should too: report archived status and stop.
- Don't re-implement what the script does. If something looks wrong in the output, fix the script (`~/.claude/skills/github-repo-analyzer/analyze.sh`) rather than working around it ad-hoc.
