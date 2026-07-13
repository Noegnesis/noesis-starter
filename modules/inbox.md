---
id: inbox
tier: core
title: Inbox & Capture
depends_on: []
suggests: []
default: true
---

## Concept
One drop zone. Everything new lands in inbox/ first and gets sorted later, so capture never has to wait on a filing decision.

## Applies when
Always — every vault needs a capture point.

## Questions
- sort_cadence — How often do you want to sort the inbox? (default: weekly)

## Creates
- inbox/

## CLAUDE.md snippet
```
- New files from outside land in inbox/ first; sort later (cadence: {{sort_cadence}}).
- When something lands in inbox/, offer to sort it before it goes stale.
```
