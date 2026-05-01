# Design

- breakdown by sections
- keep each point short
- start with `# [topic] Design Doc`
- /grill-me

## Architecture
This applies to different scope. For example, breakdown to:
- services
- code modules
- code folders

- Design top-down like a tree. Resolve each level fully before descending. Defer details
- Define clear boundary between modules
- Which module has state? What state is maintained?
- Clear expectation of each module
- Walk through a few flow and see how different modules interact
- use concise psuedo code as example

## Tools and APIs

This applies to choosing library, services, api within a library

HiL with table for numbers and short text followed by short paragraphs for longer
text.

Consider:
- maturity and adoption. use download times, github search count, etc.
- whether if one is replacing or inspired by another. If so, why
- implementation complexity. Use short sample code to compare.
- primary use case. Whether it matches our use case.
- performance. only consider when its on hot path. Benchmark for our use case if
it's easy to do and relavant
- Cost. for services


## Work Log

Each work log is docs/[date]-[topic]-design/[001]-subtopic.md

Example of work log:
- key decision
- research an area or product
- study a race condition or flow

Always have a few sentence on the top as overview. Include all relavant detail
after.

### Desicion

After each decision is made during this design session, write a work log.

Add/Update work log as we make each decision.

In overview, in one sentence each, include:
- the problem
- decision
- why

Then follow up with all relavant context, including:

- evidence and rational
- what I said that's relavent to this. include my thoughts and statements. don't
  include questions.
- alternatives
- user flows
- diagrams
- example work flow
- sample code

### Research

In overview, in one sentence each, include:
- research scope
- reason

Then follow up with all relavant context with evidence.

## Final Doc

- Do not repeat what's in requirement
- Do not explain rational unless useful for implementation
- Verify all requirement is satisfied
- Do not include what's not required in requirement

Sections:
- Architecture. top level components, boundary, expectation of each component
- Modules. optional, further breaking down the component
- Definitions. Selective list of definition for type and functions with sample
  code.
- ChangeList. Bulletin list of files with one line of what is in there and what to
  change. 





