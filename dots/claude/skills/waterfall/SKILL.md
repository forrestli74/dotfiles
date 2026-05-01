---
name: waterfall
description: Use when the user wants a disciplined waterfall workflow — requirements → design → code — with docs under docs/[date]-[topic]/. Drives the full lifecycle of a feature with structured docs, work logs, and a separate code branch.
---

# Waterfall

- file structure: `docs/[date]-[topic]/{req, design, [001]-[subtopic]}.md`
- subtopic is a history of work log
- read docs and code before start
- pickup where left off
- skip req if task is simple.
- /grill-me

## Workflow

- work in main branch
- requirement: follow [req.md](req.md)
- design: follow [design.md](design.md)
- commit related docs
- switch to new branch and worktree in ./.worktree/[topic] before starting to code
- follow [code.md](code.md) for implementation. do not touch main
- HiL verify
- squash, merge, delete worktree

## Subtopic

Each work log is `docs/[date]-[topic]/[001]-subtopic.md`

Write the log as soon as its subtopic wraps up, before opening the next one.
Do not defer logging to the end of the session.

Example of work log:
- key decision
- research a tech or product
- study a key scenario

Structure:
- a few sentence of overview
- all relavant detail
- what I said. Only include facts, opinion, decision. Don't include question.

### Decision

Overview is one sentence each on:
- the problem
- decision
- why

Details include:
- evidence and rational
- alternatives
- user flows
- diagrams
- example work flow
- sample code

### Research

Overview is one sentence each on:
- research scope/focus
- reason
