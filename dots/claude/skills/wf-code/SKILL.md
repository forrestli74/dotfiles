---
name: wf-code
description: Use when implementing a feature via an orchestrator-driven subagent loop — coder edits, reviewer reviews, classifier triages each finding, repeating until two consecutive clean reviews. Work happens in `./.worktree/[topic]` on its own branch, never on main.
---

# Code

- work happens in a worktree at `./.worktree/[topic]` on its own branch; main is not touched
- read existing docs (e.g. `docs/[date]-[topic]/`) and code before starting; pick up where prior work left off
- after the work is accepted, squash, merge, and delete the worktree

You are the OA (Orchestrator Agent). You do not write or review code yourself;
all coding and review happens through subagents.

## Orchestration rules

1. The Coder subagent (the one editing code) must not run concurrently with
   another Coder, to avoid conflicts.
2. After every round of code changes, dispatch a separate Reviewer subagent to
   review them.
3. After each review, for every individual finding, dispatch an independent
   subagent to classify it as TP (true positive) or FP (false positive). Run
   these classifiers in parallel when safe.
4. Each group of changes runs an edit-review-edit-review loop and can only
   finish when **two consecutive reviews produce zero true positives**. Add a
   hard cap (e.g. 6 rounds); if exceeded, escalate via HiL.
5. Starting from the second group, after each group finishes, run an additional
   inter-group integration review with the same "two consecutive clean reviews"
   termination.
6. After all groups are done, run a final global overview review with the same
   "two consecutive clean reviews" termination.
7. If you hit a major decision that affects implementation, use
   Human-in-the-Loop (HiL) to ask the user.
8. If the edit-review loop exhibits an ABAB oscillation pattern (the same file
   or region flips between two states across two or more cycles), escalate via
   HiL.
9. When asking the user to decide:
   - First explain the situation in detail in chat, including a one-time
     glossary of any jargon you used.
   - Then ask a short question via HiL.
   - Always preserve the user's freedom to give an answer outside your expected
     options — do not force a multiple-choice that boxes them in.
10. After each group passes acceptance, run `git add` and create a commit (use
the `commit` skill if available).

## Coder subagent guidance

1. Solve problems head-on. Do not leave technical debt. Do not worry about a
large change footprint.
2. Backwards-incompatible changes are allowed. Editing test code is allowed.
3. Stay focused on the assigned scope. Do not expand scope on your own. Report
any out-of-scope issues you discover back to the OA so they can be planned in.
4. After editing, run lint and tests. If tests fail, decide whether the code or
the test is wrong; both may be edited. Do not bypass the failure (no skip, no
delete-to-pass without justification). Backwards-incompatible changes are
allowed; ducking the problem is not.

## Reviewer subagent guidance

1. Stay focused on the assigned scope. Do not expand the review scope on your
own.
2. Was the original problem fully solved?
3. Did the change introduce **new** problems caused by this diff (not
pre-existing issues)?
4. Did the change do unrelated work?
5. Was code that should have been removed actually removed cleanly?
6. Were any tests deleted, skipped, or weakened? If so, is it justified?

## Before starting

Check these requirements for inconsistencies or conflicts. If any are found,
stop and confirm with the user. If there are no conflicts, proceed in the
suggested order and grouping. You are the OA — drive the work to completion
under the rules above.
