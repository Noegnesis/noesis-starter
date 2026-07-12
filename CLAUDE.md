# CLAUDE.md — My Second Brain

## Who I Am
[Run /vault-setup to personalize this file. Claude Code will interview you
and fill this in based on your role, projects, and goals.]

## Vault Structure
```
inbox/      ← Drop any file here. Claude Code will sort it.
daily/      ← Daily notes (YYYY-MM-DD.md)
projects/   ← Active projects and briefs
research/   ← Notes, synthesis, saved ideas
archive/    ← Completed work. Never delete, just archive.
applications/ ← Job-search kits, Facts Ledger, and the Applications tracker (optional module)
guide/      ← The how-to guide (optional install). Start at MOC - Guide.md.
```

## Context Loading Rules
When starting the day:
→ Read daily/[today's date].md if it exists
→ Check inbox/ for any unprocessed files

When working on a project:
→ Read projects/[name]/ before starting

When writing anything:
→ Read recent notes first to calibrate voice and context

## How to Maintain This Vault
- New files from outside → inbox/ first, sort later
- Daily notes → daily/YYYY-MM-DD.md
- When you create a substantive note anywhere in the vault → add a [[link]] to it
  under today's daily note's "## Linked Today" section (create the section if
  missing), grouped by top-level folder. The daily note is the same-day hub:
  one place that answers "what did I make today?" (/daily sweeps for anything missed)
- Completed work → archive/ (never delete)
- Update this file whenever your conventions change

## Available Slash Commands
- /vault-setup   — Personalize this vault for your role
- /daily         — Start the day with vault context
- /weekly        — End-of-week review from the week's daily notes
- /tldr          — Save a summary of this session to the vault
- /file-intel    — Process any folder of files through Gemini, get Obsidian-ready summaries
- /vault-health  — Audit vault content: broken links, orphans, stale MOCs
- /jobs          — Ingest a posting, score fit, tailor a kit, and track it
