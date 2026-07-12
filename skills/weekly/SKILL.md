---
name: weekly
description: Weekly review. Read the past week's daily notes, surface wins, lessons, and carry-overs, then set up the coming week. Run at the end of the week (or whenever one closes).
---

# Weekly Review

1. Collect the week: read the last 7 days of notes in `daily/` (skip gaps —
   review what exists, never nag about missed days).

2. Draft the review in `daily/` named with the full date range, e.g.
   `2026-W02 (2026-01-05 to 2026-01-11).md` — the range in the filename means
   you never have to open it to know what it covers:

# Week [ISO week] — [start date] to [end date]

## Wins
- What actually got done. Pull from the week's Top 3s and Linked Today sections — be concrete.

## Lessons
- What worked, what didn't. One honest sentence each.

## Carry-overs
- Items that surfaced during the week and never got done. For each, ask: carry, drop, or archive?

## Next week
- The 3 things that matter most. Fewer is better.

3. If `scripts/vault_health.py` exists, run
   `python scripts/vault_health.py . --pulse` and append its one-line output
   under `## Vault health` — broken links and orphans are cheapest to fix
   while the week is fresh. Skip silently if the script isn't installed.

4. Show the draft and ask: "Anything the week's notes missed?" Revise, then save.
