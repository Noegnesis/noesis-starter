---
title: 07 — Sync, Devices & Maintenance
tags:
  - setup
  - onboarding
  - sync
  - maintenance
---

# 07 — Sync, Devices & Maintenance

> **In one breath**
> A second brain you can't trust is worse than none — you'll quietly stop relying on it. This doc keeps it trustworthy: sync the vault across devices, keep the agent's config identical everywhere, audit for drift and staleness, and back up so a lost laptop is a non-event.

← [Start Here](../README.md) · prev [06 — ADHD Empowerment System](06-adhd-empowerment-system.md)

---

## Two things sync, and they're different

> [!WARNING]
> **The mistake almost everyone makes**
> Syncing your **notes** is not the same as syncing your **agent setup**. People sync the vault, switch devices, and discover the agent behaves completely differently because its config (CLAUDE.md, skills, settings) lives *outside* the vault and didn't come along.

| Layer | What it is | Where it lives | How it syncs |
|---|---|---|---|
| **The vault** | Your notes (Markdown files) | The vault folder | A file-sync tool |
| **The agent setup** | CLAUDE.md, skills, settings, hooks | Usually `~/.claude/` (outside the vault) | Deliberate copy / version control |

You have to solve **both**.

---

## Syncing the vault

> **How many devices?**
> - **One device** → skip to *Backup*. You still need backup; you don't need sync.
> - **Multiple devices** → pick a sync method below.

Options, roughly in order of "just works":

- **A real-time sync plugin** (e.g. Obsidian's own sync, or a self-hosted live-sync plugin) — handles conflicts, near-instant. Best for active multi-device editing.
- **A cloud-drive folder** (Drive/Dropbox/iCloud) — simplest, but watch for conflict files and partial syncs when two devices edit at once.
- **Git** — version history for free, great for the technically inclined, awkward for live mobile editing.

> [!TIP]
> **Decide before you create the vault**
> Where the vault lives ([02 — Obsidian Vault Setup](02-obsidian-vault-setup.md) step 1) determines your sync options. Moving a vault later breaks absolute paths in scripts and configs. Choose the location with sync in mind on day one.

---

## Syncing the agent setup: the canonical-device pattern

The robust approach when you run the agent on more than one machine:

```
Device A — CANONICAL (source of truth for config)
  → mirror to Device B
  → mirror to Device C
  
A "Setup" state doc in the vault (skills manifest, settings, install steps)
  → documents the canonical state
```

1. **Designate one device as canonical.** All config changes happen there first.
2. **Keep a "Setup" state doc in the vault** — a single Markdown file that records: which skills exist (with their content or a manifest), the settings.json contents, the global CLAUDE.md, and exact install steps. Because it's *in the vault*, it syncs everywhere automatically and is readable by the agent on any device.
3. **Mirror to other devices** by following that doc. When you set up a new machine, you (or the agent) read the Setup doc and reproduce the state.

> [!TIP]
> **The state doc is the secret**
> Treat it as the single source of truth for "how is this system built." When something changes on the canonical device, update the doc in the same breath. New device, recovered device, or just "wait, what did I configure?" — all answered by one file that travels with your notes.

---

## Drift: the silent killer, and the self-audit cure

Across devices and over weeks, configs **drift** — a skill updated on one machine, a setting changed on another, a memory that's now wrong. Left unchecked, the agent behaves inconsistently and you lose trust.

The cure is a **self-audit** routine (a skill — see [05 — Skills & Automation](05-skills-and-automation.md)) that the agent runs against the canonical Setup doc:

- Compares this device's skills/settings to the documented canonical state → flags what's stale or missing.
- Flags loaded-but-unused connectors (ties into the [connector audit](04-connectors-and-tools.md)).
- Flags memories or notes that contradict current reality.

> **When to run it**
> On returning to a device after time away, at the start of a work week, or whenever you suspect drift. "Are we drifted? What's stale?" should be a question the system can answer about *itself*.

---

## Freshness: don't trust stale notes blindly

A note that *looks* authoritative but is two months out of date will lie to you confidently. Build a lightweight freshness protocol:

- **Index/graph staleness** — if your knowledge graph hasn't rebuilt in N days, the agent should warn before relying on it and offer to refresh.
- **MOC freshness** — a recently-touched MOC is trustworthy; an old one should be supplemented with recent daily notes before you act on it.
- **Periodic notes are fresh by construction** — daily/weekly notes are created in place, so they're always current.

Bake these thresholds into [CLAUDE.md](03-the-agent-layer-claude-code.md) so the agent self-polices rather than confidently citing rot.

---

## Backup (non-negotiable, even on one device)

- Plain-text vault → trivially backed up. Sync ≠ backup (a sync also propagates a deletion). Keep an *independent* backup: periodic Git commits, a cloud snapshot, or a second drive.
- Quarantine secrets: keep credentials in a folder excluded from the graph and ideally outside what the agent can touch. ([02 — Obsidian Vault Setup](02-obsidian-vault-setup.md) `sensitive/`.)

---

## Vault hygiene (ongoing, low effort)

- **Triage the inbox** on a schedule — don't let `inbox/` become a landfill.
- **Archive finished work** — keep active folders genuinely active.
- **Watch for sync artifacts** — conflict-copy files, duplicate names; clean them periodically.
- **Prune dead links and stale memories** — a quick pass during the weekly review.

The starter automates the detection half: `/vault-health` scans for broken
wikilinks, orphaned notes, stale MOCs, and inbox backlog (read-only, with a
safe cosmetic auto-fix), and `/weekly` appends its one-line pulse so trends
surface without you asking. Self-audit above watches the *system*; this
watches the *content*.

---

## What "done with this doc" looks like

- [ ] Vault sync chosen (or backup-only if single-device)
- [ ] A Setup state doc exists in the vault and reflects reality
- [ ] One device is designated canonical (if multi-device)
- [ ] A self-audit habit (manual or scheduled)
- [ ] An independent backup that survives an accidental deletion

Your system is now durable and trustworthy. When you're ready to push past the basics, [08 — Going Further (Advanced)](08-going-further-advanced.md) covers local models, mobile control, and building your own tools.

---
← [06 — ADHD Empowerment System](06-adhd-empowerment-system.md) · next → [08 — Going Further (Advanced)](08-going-further-advanced.md)
