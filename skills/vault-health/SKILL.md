---
name: vault-health
description: Audit the vault's content health — broken wikilinks, orphaned notes, stale MOCs, inbox backlog, naming artifacts. Read-only by default, with a safe cosmetic --fix subset and an undo log. Run when the vault feels cluttered, after bulk moves or renames, or on a monthly rhythm.
---

# Vault Health

Why this matters: a well-linked, MOC-covered vault is cheap to query — the agent
routes through hubs instead of grepping everything. Broken links, orphans, and
stale MOCs quietly push every question back toward expensive blind search.

## Step 1 — Scan (read-only)

From the vault root:

```bash
python scripts/vault_health.py . --json
```

## Step 2 — Report

Summarize the JSON in this order (worst first), with counts and examples:

1. `broken_links` — each `src` → `target` that resolves to nothing
2. `orphans.active` — notes with no links in or out (daily/weekly logs don't count)
3. `stale_mocs` — MOCs older than 2 weeks with newer notes beneath them
4. `coverage` — per-folder % of notes reachable from a MOC
5. `inbox` — backlog count and oldest age
6. `naming_artifacts` / `ambiguous_basenames` — sync leftovers, duplicate names

If everything is clean, say so and stop — no ritual.

## Step 3 — Offer the safe auto-fix

Only cosmetic link repairs (case / whitespace / smart-quote mismatches with
exactly one unambiguous match) are auto-fixable. Preview first, then apply
only with the user's approval:

```bash
python scripts/vault_health.py . --fix-plan
python scripts/vault_health.py . --apply --undo .vault-health-undo.json
```

The fixer never edits notes whose frontmatter says `voice: raw`.

## Step 4 — Triage the rest with the user

- True broken links → find the intended note and fix by hand, or remove the link.
- Orphans → link each into the right MOC or project note (or archive it).
- Stale MOCs → open the MOC, fold in what's new beneath it.

Do the mechanical fixes in-session; don't end on a list of commands.

## Notes

- A note can opt out of link checks with frontmatter `vault-health: ignore`
  (for docs whose example wikilinks are illustrative).
- A hand-verified MOC can assert freshness with frontmatter `updated: YYYY-MM-DD`.
- `/weekly` runs `--pulse` for a one-line trend; this skill is the full audit.
