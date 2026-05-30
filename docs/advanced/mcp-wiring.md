# Advanced: MCP wiring (optional)

Connect live context (calendar, mail, chat) to your vault. This is opt-in and costs more tokens than CLI tools — wire it only if you need it.

## The doctrine first

Prefer **CLI > API > MCP** in that order: MCP calls cost roughly 35× a CLI call. Start with none; add one source at a time. See [04 — Connectors & Tools](../04-connectors-and-tools.md) for the full decision tree.

## When MCP is the right choice

MCP earns its keep in one scenario: when the agent needs **live, version-specific data pulled into context** before acting — for example, a documentation server that fetches the current API spec so the agent codes against reality, not its training memory. Most connectors do not fit this pattern.

## What's available

Claude Code supports MCP servers for many services (calendar, mail, drive, project management, etc.). The canonical list lives at [claude.ai/integrations](https://claude.ai/integrations) and in the Claude Code documentation.

## Before you install any MCP

Run the decision tree from doc 04:
1. Does an official CLI exist? → Use that instead.
2. Can I hard-code the one endpoint I need into a 20-line script? → Do that instead.
3. Is this something I'll use weekly+ and there's genuinely no CLI path? → Then reach for MCP.

## Audit cadence

Once installed, audit your MCP servers every 30 days:
- Used in the last 30 days? → Keep.
- CLI alternative now exists? → Replace and drop the MCP.
- Never used? → Drop (auth hygiene + token savings).

(A guided MCP setup and audit flow is planned for a later version of this tool.)
