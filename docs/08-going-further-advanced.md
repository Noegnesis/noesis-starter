---
title: 08 — Going Further (Advanced)
tags:
  - setup
  - onboarding
  - advanced
---

# 08 — Going Further (Advanced)

> **In one breath**
> None of this is required. A vault + agent + a few skills is already a powerful second brain. This doc is the menu of "once the basics are boring" upgrades: build your own CLIs, run a local model for privacy/cost, control the agent from your phone, turn your notes into a knowledge graph, and publish. Pick one that solves a real itch; ignore the rest.

← [Start Here](../README.md) · prev [07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md)

> [!WARNING]
> **Read this first**
> Everything here is **optional and additive**. Do not build any of it to feel "complete." Add a module only when a specific, recurring friction makes the basics insufficient. Premature advanced tooling is how second brains die of complexity. (The litmus test from [01 — Foundations & Philosophy](01-foundations-and-philosophy.md) still rules.)

---

## Module A — Build your own CLIs (the CLI factory)

From [04 — Connectors & Tools (CLI → API → MCP)](04-connectors-and-tools.md): when a service has no good CLI, you can *build* one. Tools exist (e.g. a "CLI factory" skill) that scaffold a command-line interface around any service — even one with no public API — from a natural-language description plus a URL or docs.

**When it's worth it:** a service you hit repeatedly that has no agent-friendly interface (a school portal, a niche SaaS, an internal tool). Build the CLI once; wrap it in a skill; never fight the raw service again.

> [!TIP]
> **This is the endgame of the connector doctrine**
> CLI → API → MCP, and if none exist, *make the CLI*. It keeps your whole tool surface fast and reliable, and portable across models (Module B).

---

## Module B — Run a local model

Swap the cloud model behind the agent for one running on your own hardware (a capable GPU + an inference server).

**Why you might:**
- **Privacy** — your most personal notes never leave your machine.
- **Cost** — no per-token bills for high-volume use.
- **Sovereignty** — the system keeps working regardless of any provider.

**What it costs you:**
- Capable hardware and setup effort (inference server, model selection, tool-parser config).
- Local models are **more sensitive to tool-output shape** — which is the load-bearing reason to have gone CLI-first all along ([04 — Connectors & Tools (CLI → API → MCP)](04-connectors-and-tools.md)). Verbose MCP JSON that a frontier model tolerates can break a smaller local model.

> **Is local worth it for you?**
> - **Yes** if privacy of personal notes is paramount, or your volume makes cloud costs sting, and you enjoy infrastructure.
> - **No / not yet** if you want the strongest reasoning with zero ops. Cloud frontier models are simply more capable today. Most people should stay cloud until a concrete privacy or cost reason forces the move.

---

## Module C — A multi-provider front-end

Rather than committing to one agent/provider, route through an abstraction layer so you can switch models (cloud or local) under a common interface.

A useful way to think about the layers:
1. **Router** — directs requests to whichever model/provider you choose.
2. **Runtime** — the agent harness that executes tools.
3. **UI** — how you interact (terminal, chat app, mobile).

**When it's worth it:** you're hedging provider lock-in, mixing local + cloud by task, or want one UI over several backends. **Skip** until you actually feel the lock-in — it's real infrastructure to maintain.

---

## Module D — Control the agent from your phone

The thought you have away from your desk is the one most likely to be lost. Mobile control closes that gap:

- **A chat-bot bridge** (e.g. a Telegram bot) → talk to the agent from your phone; voice memos get transcribed and land in your journal as raw text ([06 — ADHD Empowerment System](06-adhd-empowerment-system.md) Pattern 5).
- **Remote access** to a machine running the agent (SSH, or a small always-on server/VPS) → drive your full setup from anywhere.

**When it's worth it:** you capture a lot on the move, or you want to kick off tasks while away. This is one of the higher-ROI advanced modules for an ADHD workflow specifically — capture-anywhere is worth a lot.

---

## Module E — Turn your notes into a knowledge graph

At scale (hundreds+ of notes), reading raw files gets expensive and you miss connections. A **knowledge-graph builder** ingests a folder and produces clustered communities, a generated wiki, and a queryable structure.

**Payoff:**
- The agent **queries the graph** instead of re-reading raw files — faster, cheaper, and it surfaces non-obvious cross-topic links.
- You get an auto-generated "wiki" view of your own thinking.

**When it's worth it:** your vault is big enough that retrieval is slow or shallow, and you have stable bodies of notes (projects, research, archives) worth indexing. Re-index periodically and respect freshness ([07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md)) — a stale graph misleads.

---

## Module F — Publish / share

Your second brain can become an output engine:

- **Selective publishing** — push chosen notes to a website or digital garden.
- **Voice-matched drafting** — because you taught the agent your voice via the reflection layer ([01 — Foundations & Philosophy](01-foundations-and-philosophy.md) principle #5), it can draft posts, emails, and essays that sound like you.

**When it's worth it:** you want your private thinking to produce public artifacts. **Caution:** publishing is one-way — review carefully, and keep the personal/identity layer firmly private.

---

## A sane order to add these

```
Solid basics: vault + agent + core skills
  → Module D: mobile capture (highest everyday ROI)
  → Module E: knowledge graph (when retrieval gets slow)
  → Module A: build a CLI (when a service keeps annoying you)
     → Module B: local model (for privacy/cost)
        → Module C: multi-provider (to avoid lock-in)
  → Module F: publish (when you want output)
```

> [!TIP]
> **One at a time**
> Add a single module, live with it for a couple of weeks, and only then consider the next. Each one is a maintenance commitment. The goal was never the most elaborate system — it's the one you actually trust and use.

---

## What "done with this doc" looks like

There's no "done" here — that's the point. You've finished the onboarding when you have:

- [ ] A vault you capture into without friction ([02 — Obsidian Vault Setup](02-obsidian-vault-setup.md))
- [ ] An agent that surfaces and drafts for you ([03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md))
- [ ] A daily/weekly rhythm that catches deadlines ([05 — Skills & Automation](05-skills-and-automation.md))
- [ ] A system that's forgiving on bad days ([06 — ADHD Empowerment System](06-adhd-empowerment-system.md))
- [ ] Trust that it's durable and current ([07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md))

Everything above is gravy. Add it when a real itch demands it — never before.

---
← [07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md) · back to [Start Here](../README.md)
