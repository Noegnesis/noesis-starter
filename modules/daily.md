---
id: daily
tier: core
title: Daily Notes
depends_on: [inbox]
suggests: []
default: true
---

## Concept
One note per day (daily/YYYY-MM-DD.md): the day's hub for priorities, quick capture, and links to everything made that day.

## Applies when
Always — the daily note is the vault's heartbeat.

## Questions
- daily_focus — What should the daily note surface first? (default: top 3 priorities)

## Creates
- daily/

## CLAUDE.md snippet
```
- Daily notes live at daily/YYYY-MM-DD.md. Start the day by reading today's note.
- Surface {{daily_focus}} at the top of each daily note.
- Check inbox/ for unprocessed files when the day starts.
```
