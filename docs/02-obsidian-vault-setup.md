---
title: 02 — Obsidian Vault Setup
tags:
  - setup
  - onboarding
  - obsidian
---

# 02 — Obsidian Vault Setup

> **In one breath**
> Install Obsidian, create a small folder structure you'll actually use, agree on a frontmatter and voice convention, and add only the handful of plugins that earn their keep. You can be capturing notes in 15 minutes and refine the structure forever.

← Back to [Start Here](../README.md) · prev [01 — Foundations & Philosophy](01-foundations-and-philosophy.md)

---

## Why Obsidian (and when not to)

[Obsidian](https://obsidian.md) stores your notes as **plain Markdown files in a normal folder**. That single fact is why it's the recommended base:

- **No lock-in** — the files are yours, readable by any editor, greppable by any tool, and (crucially) directly readable by an AI agent.
- **Local-first** — works offline; you choose how to sync.
- **Extensible** — plugins, themes, and a property/database layer when you want it.
- **Free** for personal use.

> **Is Obsidian the right base for you?**
> - **Yes** if you want plain-text durability and an agent that can read/write your notes as files. (This whole guide assumes Obsidian.)
> - **Consider Logseq** if you think in outlines/bullets first.
> - **Consider Notion** if you need rich databases + real-time collaboration more than file durability — but know you're trading away easy agent access and plain-text longevity.

---

## Step 1 — Install and create a vault

1. Download Obsidian, install, **Create new vault**.
2. Put the vault folder somewhere your sync tool sees it (see [07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md) before you pick — this decision is annoying to change later).
3. That's it. The vault is just a folder; everything below is files inside it.

---

## Step 2 — Folder taxonomy

> [!TIP]
> **Branch here**
> **Just starting?** Build the **3-folder minimum** and stop. **Know you're going deep** (researcher/power-user)? Skip to the **full taxonomy**.

### The 3-folder minimum

```
inbox/         ← capture everything here, sort later
notes/         ← anything you've sorted and want to keep
archive/       ← done / inactive; never delete, just move here
```

That's a complete second brain. Capture to `inbox/`, triage into `notes/`, retire to `archive/`. **Do not add more folders until the absence of one causes a real "I can't find this" moment.** (Principle #2 in [01 — Foundations & Philosophy](01-foundations-and-philosophy.md).)

### The full taxonomy (grows over time)

The reference stack uses a numbered, actionability-ordered taxonomy (a PARA descendant). Numbers force sort order and make folders unambiguous:

```
inbox/            ← capture / quick drop zone. Sort later.
  └─ sessions/    ← AI session summaries + ad-hoc captures
daily/            ← daily notes (YYYY-MM-DD.md)
projects/         ← active projects, work, research — anything with an outcome + deadline
learning/         ← current courses / study topics (finished ones → archive)
career/           ← longer-horizon: mentors, goals, applications
identity/         ← reflections, journal, interests — the "who am I / why" layer
  ├─ journal/     ← your raw voice. AI NEVER edits this.
  └─ reflections/ ← curated, sparse, topical writing
portfolio/        ← finished, presentable artifacts
archive/          ← completed work. Never delete.
sensitive/        ← credentials only; kept out of the link graph
setup/            ← how the system itself is built (this folder lives here)
```

Key ideas you can steal even at small scale:
- **Number folders** so order is deliberate, not alphabetical.
- **Separate "active" from "archived"** — current courses vs finished, active projects vs done. Archived ≠ deleted.
- **Give identity/reflection its own home.** The "why" layer is what makes the system *yours*, not just a task pile. (See [06 — ADHD Empowerment System](06-adhd-empowerment-system.md) for why this anchors motivation.)
- **Quarantine secrets.** Credentials go in a folder excluded from search/graph and never touched by the agent.

---

## Step 3 — Frontmatter & the voice convention

Every note can carry YAML **properties** (frontmatter) at the top:

```yaml
---
title: My Note
created: 2026-05-23
tags:
  - project
status: active
voice: ai-mixed
---
```

Two conventions to adopt **before** you let an agent write (retrofitting is painful):

1. **A `status` you actually filter on** — e.g. `active | someday | done`. This powers dashboards later (see Bases below).
2. **A `voice` field** — the load-bearing one from [01 — Foundations & Philosophy](01-foundations-and-philosophy.md):

| `voice:` value | Means |
|---|---|
| `raw` | Your unedited words. AI must never modify. |
| `ai-cleaned` | AI tidied your raw text (original preserved above it). |
| `ai-mixed` | You and AI co-wrote. |
| `ai-generated` | AI wrote it; you reviewed. |

At the section level, use callouts so authorship is visible inline:

```markdown
> [!raw]
> Your exact words, transcribed from a voice memo.

> [!ai]
> The agent's summary or draft, clearly marked as not-you.
```

> [!WARNING]
> **The one rule that protects everything**
> AI-cleaned text goes **below** the original, never over it. The raw layer is sacred. Decide this now.

---

## Step 4 — The periodic-note rhythm

A second brain only surfaces deadlines if you give it a daily heartbeat. The stack runs a **three-layer periodic model** (concept introduced in [01 — Foundations & Philosophy](01-foundations-and-philosophy.md), automated in [05 — Skills & Automation](05-skills-and-automation.md)):

- **Operational daily note** (`daily/YYYY-MM-DD.md`) — AI-assisted morning briefing: your top 3 priorities and notes (calendar/tasks appear only if you've wired an optional connector — see [docs/advanced/mcp-wiring.md](advanced/mcp-wiring.md)).
- **Weekly review** — wins, lessons, next week's plan (not in the starter set — build your own skill following the pattern in [05 — Skills & Automation](05-skills-and-automation.md)).
- **Journal** (`identity/journal/...`) — your raw voice, separate, AI-untouched.

> [!TIP]
> **The daily note is also a same-day hub**
> Give it a `## Linked Today` section, and every substantive note created that day gets a `[[link]]` there (grouped by folder) — added at creation time by the agent, swept for stragglers by `/daily`. Retrieval by *when* is the one axis folders can't give you: months later, "that idea from the week of the offsite" is one daily note away. Keep it one-way (daily → note) so notes never need to know about the hub.

Start manual (a daily note template you fill in). Automate it once the agent layer is in place.

---

## Step 5 — Plugins (only what earns its keep)

Obsidian works great with **zero** community plugins. Add these only as the need appears:

| Plugin | Job | Add when… |
|---|---|---|
| **Notebook Navigator** | A cleaner, calendar-aware file explorer; resolves daily notes by date | your daily-note folder gets deep |
| **Bases** *(core)* | Database-style table/card views over frontmatter — the dashboard layer | you want "all active projects sorted by deadline" |
| **A sync solution** | Cross-device (see [07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md)) | you use more than one device |
| **A minimal theme** | Readability; some themes style Dataview/list tables as cards | the default feels cramped |

> [!TIP]
> **Plugin discipline**
> Every plugin is a dependency that can break on update and adds cognitive load. The litmus test from [01 — Foundations & Philosophy](01-foundations-and-philosophy.md) applies: does it make capture / triage / retrieve / reflect *easier*? If not, don't install it. A common trap is installing overlapping plugins (e.g. two database-like tools) — pick one per job.

### Installing a community plugin

Community plugins are **not** installed by the setup script — Obsidian installs them in-app:

> Settings → **Community plugins** → turn off *Restricted mode* (a.k.a. Safe Mode) → **Browse** → search the plugin → **Install** → **Enable**.

### Notebook Navigator — set it up for your use cases (Claude can guide this)

Notebook Navigator (NN) is the one explorer-replacement worth the dependency: a
cleaner two-pane file browser, **date-aware daily notes** (click a date, open
that day's note), and **profiles** that pin a different set of folders for each
mode of work. It's the single biggest "my vault feels navigable" upgrade,
especially once the daily-note folder gets deep.

**Ask Claude to configure it for you.** Paste this section into Claude Code and
say *"help me set up Notebook Navigator for how I actually work."* Claude should
ask, then translate your answers into NN settings:

1. **"What do you open almost every day?"** → point NN's daily-notes setting at
   your `daily/` folder and match its date format (`YYYY-MM-DD`), so clicking a
   calendar date resolves the right note instead of creating a stray one.
2. **"Which folders are noise — setup, archives, credentials?"** → add them to
   NN's **hidden folders** so the navigator stays calm.
3. **"Do you switch between distinct modes — e.g. daily ops vs deep research vs
   personal reflection?"** → if yes, build **one NN profile per mode**, each
   pinning that mode's folders + [MOCs](#step-6--mocs-curated-retrieval). Switching
   profiles then locks the view to one context — a meaningful reduction in visual
   overload (see [06 — ADHD Empowerment System](06-adhd-empowerment-system.md)).

> **Three NN quirks that waste an afternoon if you don't know them:**
> - **Hidden-folders is root-level only.** You can hide top-level folders; the
>   setting does **not** recurse into nested subfolders. Hide at the top.
> - **"Show hidden items" is a separate runtime toggle.** Flipping it on reveals
>   everything regardless of your hidden-folders config — they're two different
>   controls. If hidden folders "aren't hiding," check this toggle first.
> - **The Default profile auto-recreates on reload.** Deleting it won't stick —
>   build your custom profiles *alongside* it rather than fighting to remove it.

---

## Step 6 — MOCs: curated retrieval

Once you have more than ~50 notes, search alone starts failing you. Build **Maps of Content** — hub notes that link to everything on a topic:

```markdown
# MOC — Research

## Active threads
- [[Thread A]] — current focus
- [[Thread B]]

## Background
- [[Foundational paper notes]]
```

At larger scale, add a **top-level routing MOC** that connects cross-folder *threads* — "how does my work on X relate to my interest in Y." This is the difference between a pile of notes and a navigable mind. The agent uses these MOCs as entry points instead of blindly searching (a rule baked into its instructions — see [03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md)).

---

## What "done with this doc" looks like

- [ ] Obsidian installed, vault created in a sync-aware location
- [ ] Folders created (3-folder minimum *or* full taxonomy)
- [ ] A `voice` + `status` frontmatter convention written down
- [ ] (Optional) daily-note template in place
- [ ] You've captured at least 5 real notes

You now have a working second brain. To make it *act*, continue to [03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md). To stop here for the weekend — that's a legitimate finish line.

---
← [01 — Foundations & Philosophy](01-foundations-and-philosophy.md) · next → [03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md)
