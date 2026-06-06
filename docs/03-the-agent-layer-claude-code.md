---
title: 03 — The Agent Layer (Claude Code)
tags:
  - setup
  - onboarding
  - claude-code
  - agent
---

# 03 — The Agent Layer (Claude Code)

> **In one breath**
> Claude Code is a coding agent that runs in your terminal but works just as well on a folder of Markdown notes. Point it at your vault, teach it who you are with a `CLAUDE.md`, set sane permissions, and it can read across your notes, draft in your voice, surface deadlines, and maintain the system. This doc gets the agent installed and *governed*.

← [Start Here](../README.md) · prev [02 — Obsidian Vault Setup](02-obsidian-vault-setup.md)

---

## What the agent layer actually is

[Claude Code](https://claude.com/claude-code) is an AI agent that can read and edit files, run commands, and call external services — all from your terminal (also available as desktop, web, and IDE extensions). It was built for software, but a vault of Markdown files *is* a codebase the agent can navigate. That's the whole trick.

What it unlocks over a plain vault:

- **Cross-note retrieval** — "what did I decide about X?" answered by reading the relevant notes, not just keyword search.
- **Voice-matched drafting** — it learns your style from your reflections and writes *as* you (with attribution).
- **Surfacing** — pulls today's deadlines and tasks into a morning briefing so nothing stays invisible.
- **Maintenance** — sorts your inbox, archives finished work, audits its own setup for drift.

> **Do you need an agent at all?**
> If a plain vault already feels like enough upkeep, skip this doc. Come back when manual sorting/surfacing becomes the friction. The agent is an accelerant, not a prerequisite.

---

## Step 1 — Install & point it at your vault

1. Install Claude Code (CLI, desktop, or IDE extension — the CLI is the most flexible).
2. Open a terminal **in your vault folder** and start it there. The folder you launch from is its working directory — its "world."
3. Confirm it can see your notes: ask it to list your top-level folders.

> [!TIP]
> **One agent, one vault**
> Launch the agent from the vault root so every relative path it reads/writes lands inside the vault. Running it from your home directory and pointing at the vault by absolute path also works, but rooting it in the vault keeps things clean.

---

## Step 2 — The dual-`CLAUDE.md` pattern (the most important step)

`CLAUDE.md` is the agent's operating manual — automatically loaded into context every session. The reference stack uses **two layers**, and the split matters:

- **Global** (`~/.claude/CLAUDE.md`) — who you are, universal preferences, defaults that should hold in *any* project (e.g. "ask clarifying questions until you're confident," "prefer the smallest next step when I'm stuck").
- **Vault-local** (`<vault>/CLAUDE.md`) — vault-specific: the folder taxonomy, the voice rules, routing instructions ("when I mention a project, read its folder first"), naming conventions.

### The fault-tolerant inlining pattern

A subtle, hard-won refinement: **inline the load-bearing essentials into the global file**, even if they're also documented elsewhere. Why? If a sync hiccup means the vault file isn't loaded, or you're working from a different machine, the critical rules still apply. The global file says, in effect: *"Read the vault's full context file for detail — but here are the essentials inlined so the rules hold even if that read is skipped."*

> **Global CLAUDE.md skeleton**
> ```markdown
> ## Who I am
> [one paragraph: role, what you're optimizing for, any executive-function context]
>
> ## Vault structure (essentials)
> [the folder taxonomy, inlined]
>
> ## Voice attribution (load-bearing)
> [the raw/ai-cleaned/ai-mixed rules — never edit `voice: raw`]
>
> ## Context rules (always apply)
> - When I mention a deadline → check today's daily note + latest weekly review
> - When I mention a project → read its folder before answering
> - When I seem stuck → offer the smallest possible next action, not a plan
> - When integrating a service → prefer CLI → API → MCP (see doc 04)
>
> ## Defaults
> - Plan first for multi-step work; ask until ~95% sure of intent
> - Capture fast, sort on a schedule
> ```

> [!WARNING]
> **Don't duplicate everything**
> Inline *essentials*, redirect for *detail*. Full duplication means two files drift out of sync. The shape is "essentials inline + pointer to the full doc," not "copy everything twice."

---

## Step 3 — Settings & permission posture

Claude Code reads a `settings.json` (global at `~/.claude/`, and per-project). The decision that matters most for a notes vault is **how much it asks before acting**:

| Mode | Behavior | Good for |
|---|---|---|
| **Default (ask)** | Prompts before edits/commands | Learning the tool; high-stakes repos |
| **Accept edits** | Auto-applies file edits, still asks for commands | Day-to-day note work |
| **Bypass permissions** | Acts without prompting | A vault you trust it in, where prompts are pure friction |

The reference stack runs **bypass permissions** in the vault — the notes are backed up and version-controllable, so the cost of a bad edit is low and the ergonomic win is large. **Start more conservative** and loosen as you build trust.

> [!TIP]
> **What else lives in settings.json**
> Environment variables, a custom statusline, allow/deny lists for specific commands, and **hooks** (automation that fires on events — covered in [05 — Skills & Automation](05-skills-and-automation.md)). You don't need any of it on day one.

---

## Step 4 — Persistent memory

Beyond `CLAUDE.md`, the agent can keep a **file-based memory** — small notes-to-self that persist across sessions (e.g. "the user's vault is at this path," "this project's deadline is X"). The pattern:

- One fact per file, with frontmatter (`type: user | feedback | project | reference`).
- A `MEMORY.md` index, loaded each session, with a one-line pointer per memory.
- Before saving, check for an existing memory to update rather than duplicate; delete ones that turn out wrong.

> [!TIP]
> **What belongs in memory vs the vault**
> **Vault** = your knowledge. **Memory** = the agent's operating knowledge *about you and your work* that isn't already in the notes. Don't store in memory what the vault already records — store what was non-obvious and would otherwise be re-learned every session.

---

## Step 5 — Context discipline

The agent has a finite context window. Two habits keep it sharp:

- **Route, don't grep.** Tell the agent (in `CLAUDE.md`) to enter through a MOC or a specific folder rather than scanning the whole vault. Cheaper and more accurate. (This is why [02 — Obsidian Vault Setup](02-obsidian-vault-setup.md) §6 builds MOCs.)
- **Clear between unrelated tasks; compact when context fills.** Start fresh for a new topic instead of dragging an unrelated history along.

> **Routing rules pay for themselves**
> A rule like *"when I mention a person, check the relationships note first — never grep the whole vault for a name"* turns a 40-file scan into a 1-file read, and a vague answer into a precise one.

---

## What "done with this doc" looks like

- [ ] Claude Code installed and launched from the vault
- [ ] A global `~/.claude/CLAUDE.md` with who-you-are + inlined essentials
- [ ] A vault `CLAUDE.md` with taxonomy, voice rules, and routing
- [ ] A permission mode chosen (start conservative)
- [ ] You've asked it one real cross-note question and gotten a good answer

The agent can now think *with* you. Next, govern how it reaches the outside world: [04 — Connectors & Tools (CLI → API → MCP)](04-connectors-and-tools.md). To make it *do recurring work*, go to [05 — Skills & Automation](05-skills-and-automation.md).

---
← [02 — Obsidian Vault Setup](02-obsidian-vault-setup.md) · next → [04 — Connectors & Tools (CLI → API → MCP)](04-connectors-and-tools.md)
