---
name: wf-req
description: Use when capturing requirements for a new feature or project with MVP scope — produces a requirements doc under `docs/[date]-[topic]/req.md` covering user flows, edge cases, follow-ups, and explicit non-goals.
---

# Requirement

- doc lives at `docs/[date]-[topic]/req.md`
- read existing docs and code before starting; pick up where prior work left off
- only include bare minimum to be functional, MVP mentality
- breakdown by sections
- keep each point short

## Find Related Products

- Research online for any related products
- Find one or two that is most related
- Fully understand the product's target user, use flow, selling point
- Don't spend too much time, if nothing found, continue

## Section Breakdown

- All sections are optional, don't include if it's trivial

### Overview

- what platform it is on
- what kind of user it serves
- include motivation, keep it short, one or two sentence.
- draw connection with comparable app. highlight

### API
- only include if user need to interact with API.
- each item should include exact format, precondition, postcondition, etc.

Examples:
- function call
- file names
- file format
- url

### User Flows

- break down by different flows
- use concrete values in flow. Example: Alice opens the app and says "I want to
  buy 100 apples"
- each user flow should be a sequence of user interaction and side

Examples:
- installation / setup
- reading some data
- writing some data

### Edge Cases

- similar to user flow
- ok not to have any edge cases
- only list user error or unreliable dependency failure mode
- do not need to include things like installation failure, common service down,
  etc.

### Follow up

- list of things to consider later on
- bullet point style, one sentence each
- still make sure it's about requirement, not implementation
- this sometimes is a big list. don't hesitate to add many lines

### Will not do

Format is similar to follow up. but tracks things we are not going to do. So
that you don't ask again.

## Do not include
- implementation detail
- feasibility
- architecture
- how production ready it is
- customization, use sensible default
- logging, mention in implementation later, use sensible default

If I talk about these above, warn me.
