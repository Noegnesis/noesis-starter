---
title: 05 — Skills & Automation
tags:
  - setup
  - onboarding
  - skills
  - automation
---

# 05 — Skills & Automation

> **In one breath**
> A **skill** is a reusable workflow you teach the agent once and invoke forever (often as a `/slash-command`). **Hooks** run automation on events. **Scheduling** runs work on a timer. Together they turn the agent from "smart assistant you prompt each time" into "system that runs your daily rhythm." This doc shows the core skills to start with and how to grow your own.

← [Start Here](../README.md) · prev [04 — Connectors & Tools (CLI → API → MCP)](04-connectors-and-tools.md)

---

## What a skill is

A skill is a folder with a `SKILL.md` that describes **when to use it** and **what to do**. The agent reads the description, decides if it's relevant, and follows the steps. You invoke it explicitly (`/daily`) or the agent triggers it when your request matches.

```
You: '/daily' or 'start my day'
  → Agent matches a skill?
     → Yes: Loads SKILL.md, follows the steps
            → Vault note created/updated, services queried, etc.
     → No:  Answers normally
```

The power: a skill bundles *your* exact workflow — which folders to read, what format to write, which CLI to call — so the result is consistent every time and you never re-explain it.

---

## The core skill set for a second brain

Start with a small, high-leverage set. These map directly onto the four jobs from [01 — Foundations & Philosophy](01-foundations-and-philosophy.md):

| Skill | Job it serves | What it does |
|---|---|---|
| **`/daily`** | Surface (retrieve) | Builds today's briefing: opens/creates the daily note, reads your vault (today's note, `inbox/`, projects), surfaces the **top 3 priorities**, asks what you're working on (calendar/mail can be added later by wiring a connector — see [docs/advanced/mcp-wiring.md](advanced/mcp-wiring.md)) |
| **`/weekly`** | Reflect | A weekly review: wins, lessons, next week's plan, seeded from the week's daily notes **(not shipped — build your own with the skill-authoring pattern in this doc)** |
| **`/tldr`** | Capture | Saves a summary of the current session (decisions, things to remember, next actions) into the right folder |
| **A capture/sort skill** | Triage | Processes the inbox: classifies each item, proposes a home, files on approval |
| **A self-audit skill** | Maintain | Checks the system itself for drift/staleness (see [07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md)) |

> **Build the daily loop first**
> If you do nothing else, get a `/daily` working. Surfacing deadlines every morning is the single highest-leverage automation — it's the thing a passive vault *cannot* do for you, and it's the backbone of the [ADHD system](06-adhd-empowerment-system.md).

---

## Slash commands

A skill exposed as `/name` is a **slash command** — a named entry point you type. The starter set ships four commands:

- `/vault-setup` — interview + personalize your vault and CLAUDE.md
- `/daily` — morning briefing: daily note + top 3 priorities
- `/tldr` — save a structured session summary to the vault
- `/file-intel` — process a folder of files into summaries

You don't memorize syntax; you type the verb and the agent runs the workflow.

---

## Authoring your own skill

The fastest way to a new skill: **do the workflow once manually, then ask the agent to package it.** The loop:

1. **Do it by hand** with the agent (e.g., "summarize this meeting and file it under the project").
2. **Capture it** — "make that a reusable skill called `/meeting-notes`."
3. **Validate** — does the trigger description fire on the right phrasings? Does it duplicate an existing skill?
4. **Refine** — tighten the steps so the next run needs no babysitting.

> **A good SKILL.md description is a *trigger*, not a title**
> Bad: "Meeting notes skill." Good: "Use when the user shares a meeting transcript or says 'write up this meeting' — summarizes, extracts action items, files under the relevant project." The description is how the agent *decides* to use it, so write it as a when-to-fire rule.

> **DRY your skills**
> Before writing a new skill, check whether an existing one already covers it. A sprawl of near-duplicate skills is as bad as a sprawl of plugins — the agent gets ambiguous matches. One skill per distinct job.

---

## Hooks: automation on events

Hooks are commands the **harness** runs automatically on events (session start, before/after a tool runs, on stop). Crucially, *the harness* executes them, not the agent's goodwill — so they're how you enforce "always do X."

Examples a second brain might use:
- **On session start** — load a context file or print a digest.
- **After a note is written** — run a formatter or update an index.
- **A nudge** — remind you to journal if today's entry is empty.

> **Memory/preferences can't enforce behavior — hooks can**
> "From now on, always do X after Y" is a *hook*, not a note-to-self. If you need something to happen reliably and automatically, it belongs in settings/hooks, not in a CLAUDE.md request the agent might forget under load.

---

## Scheduling & loops

Two more automation shapes:

- **Scheduled runs** — a cron-style schedule that runs an agent task on a timer (e.g., a 7am `/daily` for a vault briefing — note: calendar/mail in that briefing requires the optional connector from [docs/advanced/mcp-wiring.md](advanced/mcp-wiring.md); a Sunday `/weekly` once you've built that skill).
- **Loops** — run a prompt or command on a recurring interval within a session (e.g., "check the deploy every 5 minutes"), or let the agent self-pace.

> **How automated do you want to be?**
> - **Hands-on** → keep skills manual; you type `/daily` when you sit down. Most people start (and happily stay) here.
> - **Hands-off** → schedule the daily/weekly so the briefing is waiting for you. Add this once the manual versions have proven themselves — automating a workflow you haven't validated just automates the bugs.

---

## What "done with this doc" looks like

- [ ] At least one skill working (`/daily` recommended)
- [ ] You know how to turn a one-off workflow into a reusable skill
- [ ] You understand hooks = enforced automation, skills = invoked workflows
- [ ] You've decided your automation posture (hands-on vs scheduled)

If executive function is your core challenge, the next doc is the payoff — it assembles all of the above into a support system: [06 — ADHD Empowerment System](06-adhd-empowerment-system.md).

---
← [04 — Connectors & Tools (CLI → API → MCP)](04-connectors-and-tools.md) · next → [06 — ADHD Empowerment System](06-adhd-empowerment-system.md)
