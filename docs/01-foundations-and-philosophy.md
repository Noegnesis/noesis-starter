---
title: 01 — Foundations & Philosophy
tags:
  - setup
  - onboarding
  - second-brain
---

# 01 — Foundations & Philosophy

> **In one breath**
> A second brain works because human memory is for *having* ideas, not *storing* them. You offload storage and retrieval to a trusted system, which frees your mind for thinking. Add an AI agent and the system also does work — sorting, surfacing, drafting — so the cost of staying organized drops below the cost of not bothering.

← Back to [Start Here](../README.md)

---

## The four jobs (the only model you must internalize)

Everything downstream is in service of one loop:

```
CAPTURE → TRIAGE → RETRIEVE → REFLECT -.-> CAPTURE
```

| Job | The question it answers | The failure mode it prevents |
|---|---|---|
| **Capture** | "How do I get this out of my head *right now*?" | Losing the thought because saving it had friction |
| **Triage** | "Where does this belong, and when do I decide?" | Either chaos (no structure) or paralysis (deciding at capture time) |
| **Retrieve** | "Can I find it again when it matters?" | A graveyard of notes you never reopen |
| **Reflect** | "What does all this *mean* for what I do next?" | Hoarding information that never becomes judgment |

> [!TIP]
> **The litmus test for any tool or habit**
> Does it make one of these four jobs **easier**? If not, it's decoration. This single question kills most of the over-engineering that sinks new second brains.

---

## Why it works (the cognitive case)

You don't need neuroscience to use a second brain, but understanding *why* it works keeps you from fighting it.

- **Working memory is tiny and volatile.** You hold a handful of items for seconds. A second brain is unlimited and permanent. Stop competing.
- **The Zeigarnik effect:** open loops (unfinished tasks, un-captured ideas) consume background attention until closed. *Writing something down closes the loop* — even if you never act on the note. This is why capture reduces anxiety, not just disorganization.
- **Externalized executive function.** Prioritizing, sequencing, remembering deadlines, and starting tasks are *executive functions*. For people with ADHD — or anyone under load — these are exactly the functions that fail first. A second brain externalizes them: the system remembers the deadline, surfaces the next step, and lowers the activation energy to start. (This is the heart of [06 — ADHD Empowerment System](06-adhd-empowerment-system.md).)
- **Retrieval beats recall.** It is far easier to *recognize* the right note from a good index than to *recall* a fact cold. Good structure (folders, links, MOCs) is recognition scaffolding.

---

## The five principles

These are the non-negotiables. The tools change; these don't.

### 1. Capture fast, sort slow
Capture must be **frictionless and judgment-free**. One inbox, always reachable, no "where does this go?" at the moment of capture. Sorting is a *separate, scheduled* activity. Conflating the two is the #1 reason people abandon their systems — every capture becomes a micro-decision, and micro-decisions are where avoidance lives.

> **Worked example:** the stack uses a single `inbox/` folder. Anything new lands there. Triage happens later, deliberately — often with the agent asking "want me to sort this now?"

### 2. Progressive structure, not premature structure
Don't design the perfect taxonomy on day one. Start with 3 folders. Add structure only when the *absence* of it causes a real retrieval failure. Structure should grow from pain, not speculation.

> **Worked example:** a minimal vault starts with just `inbox/`, `notes/`, and `archive/`. Expand only when you genuinely feel the friction of not having more.

### 3. Plain text, no lock-in
Your second brain should outlive any app. Markdown files in a folder are readable in 30 years, syncable by any means, and greppable by any tool — including an AI agent. Proprietary formats hold your thinking hostage. This is why the stack is built on Obsidian (Markdown files on disk), not a database you can't export.

### 4. Curated retrieval, not just search
Search finds what you remember to look for. **Maps of Content (MOCs)** — hand-built hub notes that link to related notes — surface what you'd never think to search for. The best systems layer three retrieval modes:
- **Folders** for "where does this live" (one home per note)
- **Links / MOCs** for "what relates to this" (many connections per note)
- **Search / agent** for "find me anything matching X"

### 5. Separate the voices (authorship is load-bearing)
Once an AI agent can write into your vault, you must be able to tell, instantly and forever, **who wrote what**. Blurring your raw voice with AI-generated text corrupts the one thing a second brain must protect: your authentic record of your own thinking. The stack solves this with a **three-layer voice model**:

| Layer | Who writes it | Rule |
|---|---|---|
| **Operational** | You + AI together | AI-assisted daily briefings, project notes. Marked as co-authored. |
| **Journal** | You only — raw | Voice memos, end-of-day dumps. **AI never edits this. Ever.** |
| **Reflection** | You, curated | Sparse, considered, topical writing. AI reads it to learn your voice; writes only when asked. |

Voice attribution is enforced with a frontmatter field (e.g. `voice: raw | ai-cleaned | ai-mixed | ai-generated`) and section-level callouts (`> [!raw]` for your words, `> [!ai]` for the agent's). An AI-cleaned version goes *below* the original — it never overwrites it.

> [!WARNING]
> **Why this matters more than it sounds**
> The first time an agent "helpfully" rewrites your raw journal entry into polished prose, you lose the original forever and you stop trusting the system with anything personal. Decide the voice rules *before* you let an agent write. This is the one foundation that's expensive to retrofit.

---

## Where this comes from (lineage, briefly)

You're not inventing this. The stack borrows the best of several traditions — worth knowing so you can read deeper where you want:

- **PARA** (Tiago Forte) — organize by *actionability*: Projects, Areas, Resources, Archive. The folder taxonomy in [02 — Obsidian Vault Setup](02-obsidian-vault-setup.md) is a PARA descendant.
- **CODE** (also Forte) — the capture-to-output pipeline: Capture, Organize, Distill, Express. This is the "four jobs" loop with an output emphasis.
- **Zettelkasten** (Niklas Luhmann) — atomic, densely-linked notes. The source of the "links and MOCs over folders" instinct.
- **Bullet Journal** (Ryder Carroll) — rapid logging and migration. The source of "capture fast, triage on a schedule," and the periodic-note rhythm (daily / weekly reviews) in [05 — Skills & Automation](05-skills-and-automation.md).

> [!TIP]
> **Don't pick one orthodoxy and obey it**
> Each tradition over-indexes on one of the four jobs. Take the principle, leave the dogma. The stack is deliberately a hybrid.

---

## The agent-augmented twist (why add AI at all)

A pure note system is passive — it stores what you put in and waits. The leap this guide makes is adding an **agent layer** (Claude Code) that can *act* on the vault:

- It **reads** across your notes to answer "what's on this week?" or "what did I decide about X?"
- It **drafts** in your voice (because you taught it via the reflection layer).
- It **surfaces** — pulls today's deadlines into a morning briefing so they're never invisible.
- It **maintains** — sorts the inbox, archives finished work, audits itself for drift.

The agent turns the second brain from a filing cabinet into a **collaborator**. The cost: you must teach it who you are (the CLAUDE.md in [03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md)) and govern how it connects to the world (the doctrine in [04 — Connectors & Tools (CLI → API → MCP)](04-connectors-and-tools.md)).

> **Decision point**
> **Do you want an agent layer at all?**
> - **Not yet** → stop after [02 — Obsidian Vault Setup](02-obsidian-vault-setup.md). A plain Obsidian vault is already a real second brain. Come back when manual upkeep annoys you.
> - **Yes** → continue to [03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md). This is where the system starts working *for* you.

---

## What "done with this doc" looks like

You can answer:
1. What are the four jobs, and the one-question litmus test?
2. Why is capture separate from sorting?
3. What are the three voice layers and why must they stay separate?
4. Do you want an agent layer — yes or not yet?

If yes to #4, go to [03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md). Otherwise, go build the vault: [02 — Obsidian Vault Setup](02-obsidian-vault-setup.md).

---
← [Start Here](../README.md) · next → [02 — Obsidian Vault Setup](02-obsidian-vault-setup.md)
