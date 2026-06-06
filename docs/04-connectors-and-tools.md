---
title: 04 — Connectors & Tools (CLI → API → MCP)
tags:
  - setup
  - onboarding
  - tools
  - mcp
  - cli
---

# 04 — Connectors & Tools (CLI → API → MCP)

> **In one breath**
> The moment your agent needs to touch the outside world — calendar, email, the web, your file types — you face a choice of *how* to connect it. There's a correct default ordering: **CLI → API → MCP**. Get the doctrine right and your agent stays fast, cheap, and reliable. Get it wrong and you bleed tokens and reliability. This doc gives you the doctrine plus a starter toolbelt.

← [Start Here](../README.md) · prev [03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md)

---

## The doctrine (read this even if you skip the rest)

When you want the agent to interact with **Service X**, prefer these in order:

> **CLI → API → MCP**

Here's why, and it's not arbitrary:

| | **CLI** | **API** | **MCP** |
|---|---|---|---|
| Built for | Agents | Code | Tool discovery |
| Output shape | Short, pre-formatted (~200 tokens) | Raw JSON (often huge) | Tool registry + raw JSON |
| Reliability on hard tasks | ~100% | High | ~72% |
| Token cost per call | 1× | 2–5× | **~35×** |
| Auth | One-time at install | Per call | Varies, often fragile |

- **CLI wins** because it was *built for* an agent to consume: short, structured, idempotent output. A CLI returns ~200 tokens where the equivalent raw API call returns 50KB of JSON the agent must parse in-context.
- **API loses** for agents because it was built for *human-written code* that wraps, parses, and formats the response. Make the agent do all that and you burn tokens for work the API consumer was supposed to do.
- **MCP loses** for two compounding reasons: its outputs are still raw API payloads (just routed differently), and loading many MCP servers adds tool definitions the agent carries around. Per-invocation cost is the killer (~35× a CLI on the same task).

> [!WARNING]
> **The default everyone gets wrong**
> "Just install the MCP" is the *most expensive* option almost every time. Reach for it last, not first.

### The one legitimate MCP use-case
MCP is the right tool when its entire job is to **pull live, version-specific data *into* context before the agent acts** — for example, a docs server that fetches current library documentation so the agent codes against the real API, not its stale training memory. That's a "needs to be MCP" pattern. Most connectors aren't.

---

## The decision tree

```
Want the agent to use Service X?
  → Official CLI exists? → Yes → Use the CLI. Wrap in a skill if used often.
                         → No  → Public API exists?
                                   → Yes → Hard-code the ONE endpoint you need into a small script/skill.
                                           Don't load the whole API surface.
                                   → No  → MCP server exists?
                                             → Yes → Used weekly+ AND no CLI buildable?
                                                       → Yes → Install the MCP.
                                                       → No  → Skip it.
                                             → No  → Build a CLI yourself.
```

> [!TIP]
> **"Hard-code the one endpoint"**
> You rarely need a service's *whole* API. If you only ever "create a calendar event," write a 20-line script that does exactly that and nothing else. The agent calls your script, not the sprawling API.

---

## Audit what you've already loaded

If you connected a bunch of MCP servers early (everyone does), run a periodic audit:

1. List every connector/MCP currently loaded.
2. For each: **have I actually used it in the last 30 days?** and **is there a CLI alternative?**
3. **Drop** the never-used ones (auth-hygiene + cognitive win). **Replace** heavily-used ones that have a CLI (capability preserved, cost slashed). **Keep** the genuine "needs-to-be-MCP" ones.

This audit becomes a recurring check — see the self-audit pattern in [07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md).

---

## A starter toolbelt (the CLI-shaped tools worth having)

These are the kinds of command-line tools this stack leans on. Add them as needs arise — not all at once.

| Tool / category | What it does | The job it serves |
|---|---|---|
| **Vault CLI** (e.g. an Obsidian CLI) | Read/create/search notes, edit properties, manage tasks from the command line | The agent's primary, *correctly-shaped* interface to the vault |
| **Knowledge-graph builder** | Turns a folder of notes into a clustered, queryable graph + wiki + audit report | Retrieval at scale: query the graph instead of re-reading raw files |
| **Web-content extractor** | Pulls clean Markdown from a web page, stripping nav/clutter | Reading articles/docs without wasting tokens on page chrome |
| **File processor** | Extracts + summarizes PDFs, slides, spreadsheets, docs into vault-ready notes | Capture from non-Markdown sources |
| **Workspace CLI** (calendar/email/drive) | One CLI covering an entire productivity suite | Replaces several heavy MCP connectors at once |
| **Media / activity pulls** | Imports listening/reading/activity history into the vault | Auto-capturing the parts of life worth logging |

> [!TIP]
> **Wrap your most-used CLI calls in skills**
> A CLI you invoke often deserves a [skill](05-skills-and-automation.md) wrapper so natural language ("summarize this folder") maps to the right command. The CLI is the engine; the skill is the steering wheel.

---

## When your model is local (a forward note)

If you ever run the agent on a **local LLM** instead of a cloud model (see [08 — Going Further (Advanced)](08-going-further-advanced.md)), the CLI → API → MCP doctrine gets *stronger*, not weaker:

- Local models are more sensitive to verbose, ill-shaped tool output — pre-formatted CLI text is far more reliable than raw JSON.
- Every wasted token of MCP payload competes with your limited context/VRAM for actual vault content.
- The break-even point for "should I build a CLI wrapper" moves *earlier*.

So: tools you build CLI-first today keep working when you change the model underneath. That portability is a feature.

---

## What "done with this doc" looks like

- [ ] You can state the CLI → API → MCP ordering and why
- [ ] You've audited your loaded connectors and dropped the dead ones
- [ ] At least one CLI tool wired in (a vault CLI is the natural first)
- [ ] You know the *one* legitimate reason to reach for MCP

To make these tools fire on command (or on a schedule), continue to [05 — Skills & Automation](05-skills-and-automation.md).

---
← [03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md) · next → [05 — Skills & Automation](05-skills-and-automation.md)
