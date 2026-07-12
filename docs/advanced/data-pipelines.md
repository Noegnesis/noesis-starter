# Advanced: Wiring live data into your daily note (optional)

Your daily briefing gets dramatically more useful when it carries live facts — open tasks, yesterday's sleep, this week's spending, whatever you actually track. This doc is the reusable recipe for wiring **any** external service into `/daily`, distilled from a stack that has shipped the same shape four times (task manager, health tracker, budget, job pipeline).

## The shape

```
scripts/<source>/cli.py  →  refresh --json  →  /daily renders a section
```

1. **A small Python CLI per source**, living in `scripts/<source>/`. It owns the API calls, auth, and caching. Its contract: `refresh --json` prints one compact JSON object and exits.
2. **The skill calls the CLI, the agent only renders.** `/daily` runs each source's `refresh --json`, then formats a short section in today's note (`## Tasks`, `## Body`, `## Money`, …). The agent never parses raw API responses — that's the CLI's job, per the CLI-first doctrine in [04 — Connectors & Tools](../04-connectors-and-tools.md).
3. **Per-source failure isolation.** A dead API prints an error JSON (`{"error": "..."}`); the skill notes "tasks unavailable today" and moves on. One flaky service must never sink the whole briefing.

## The contract, concretely

```python
#!/usr/bin/env python3
"""cli.py — minimal daily-note data source."""
import json, sys

def refresh():
    # call your service here; keep the output SMALL and pre-formatted
    return {"open_tasks": 3, "due_today": ["renew passport"], "streak_days": 12}

if __name__ == "__main__":
    try:
        print(json.dumps(refresh(), ensure_ascii=False))
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(0)  # never crash the briefing
```

And the matching line in your `/daily` skill:

> Run `python scripts/tasks/cli.py` and render the result as a `## Tasks` section (2-4 lines). If the JSON has an `error` key, write one line saying tasks are unavailable and continue.

## Hard-won gotchas

- **A skill-invoked CLI must be a real script the agent can run by path** (or a PATH-installed executable) — not a shell alias or function from your dotfiles. Non-interactive shells (`bash -c`, which is how agents run commands) don't source `.bashrc`, so aliases silently don't exist there.
- **Keep secrets in `.env` files outside the vault's graph** (the starter's `.env` pattern, or a `sensitive/` folder excluded from sync and search). Never in the CLI, never in a note.
- **Idempotent writes only.** If the CLI stores anything (a cache, a ledger), upsert by a stable ID from the source system so re-runs never duplicate.
- **Render rollups, not raw data.** The daily note gets "3 open, 1 due today" — not 200 rows of JSON. Raw data stays outside the vault; the vault gets what a human wants to glance at.
- **Keep the section regenerable.** `/daily` should be able to rewrite its section from a fresh `refresh` without touching anything you wrote by hand elsewhere in the note.

## When to reach for MCP instead

Almost never for daily-note data — this is exactly the high-frequency, low-complexity traffic where the CLI wins on cost and reliability (see [the doctrine](../04-connectors-and-tools.md)). MCP earns its place for interactive, exploratory access to a service, not for a scheduled "fetch me 5 numbers" call.
