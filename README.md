# Noesis Starter

Stand up your own second brain — an Obsidian vault guided by Claude Code — in under an hour.

## Quick Start

### macOS (primary)
> Note: the macOS installer is in **beta** — verifying on hardware. If anything fails, the script prints a manual step; nothing is destructive.

```bash
git clone https://github.com/Noegnesis/noesis-starter && cd noesis-starter
bash setup.sh
```

Check your machine first without installing anything:

```bash
bash setup.sh --check
```

### Windows

```powershell
git clone https://github.com/Noegnesis/noesis-starter; cd noesis-starter
powershell -ExecutionPolicy Bypass -File setup.ps1
```

Prereq check only: `powershell -ExecutionPolicy Bypass -File setup.ps1 -Check`

### Already have a vault?

Don't start from scratch — add the Noesis layer to your existing Obsidian vault
without risking your notes, wikilinks, or Claude Code setup. See
**[Augmenting an existing vault](docs/augmenting-an-existing-vault.md)** (Windows + macOS).

## What gets installed

Obsidian, Claude Code, Python deps (in an isolated venv), and the core skills (`/vault-setup`, `/daily`, `/tldr`, `/file-intel`) both in this vault and globally.

## Going deeper

**📚 The full guide — pick your path → [docs/README.md](docs/README.md)**

Four reading paths (Weekend Minimalist · Researcher · ADHD-First Builder · Power User), plus `docs/advanced/` for optional layers (typed memory, MCP wiring, agent system, ADHD-friendly patterns). If you let setup install it, the same guide lives inside your vault under `guide/`.

## Credits

The installer's fresh-user hardening is adapted, with thanks, from Mark Kashef / Prompt Advisers' [second-brain](https://github.com/earlyaidopters/second-brain) (MIT). This is an independent clean-room template; see `LICENSE`.

---

## What is this?

You've tried to build a second brain before. Maybe Notion. Maybe Apple Notes. Maybe a folder of markdown files you swore you'd organize. Every time, the same outcome: you'd set it up, use it for a week, then forget it existed.

The problem was never the tool. **It was that you had to remember to use it.**

This wires **Obsidian** (your local knowledge vault) to **Claude Code** (your AI agent) so that:

- Claude Code **reads your notes** before answering — it knows your projects, your voice, your context
- Claude Code **writes your notes** after working — your vault builds itself from your sessions
- Everything stays **local, private, and yours** — no cloud lock-in, no subscription creep

The result: an AI that knows who you are from the first prompt of every session.

---

## How the vault is structured

```
noesis-starter/
├── CLAUDE.md        ← Read at every session start. Personalized by /vault-setup.
├── memory.md        ← Session log. Updated by Claude Code after each conversation.
├── inbox/           ← Drop zone. Anything new lands here first.
├── daily/           ← Daily notes (YYYY-MM-DD.md). Your running log.
├── projects/        ← Active projects. Claude reads the relevant one before helping.
├── research/        ← Synthesized knowledge. Sources, notes, ideas.
└── archive/         ← Completed work. Never delete — just archive.
```

**The compounding effect:**
- Session 1: Claude knows your folder structure
- Session 5: Claude knows your projects, your voice, your preferences
- Session 20: Claude is your personalized operating system

---

## Slash commands

Four commands come pre-installed:

| Command | What it does |
|---------|-------------|
| `/vault-setup` | Interviews you (role, projects, goals) and generates your personalized vault structure + CLAUDE.md + custom slash commands |
| `/daily` | Starts your day — reads today's note or creates one, surfaces your top priorities, asks what you're working on |
| `/tldr` | At the end of any session, saves a structured summary to the right folder in your vault automatically |
| `/file-intel` | Point it at any folder — processes every file and generates Obsidian-ready summaries into your inbox |

Skills are installed both locally (in your vault) and globally (`~/.claude/skills/`), so slash commands work from any folder.

---

## After setup

### 1. Open Claude Code in your vault
```bash
cd noesis-starter
claude
```

### 2. Run your first command
```
/vault-setup
```

Claude Code will interview you about your role and work, then generate a personalized `CLAUDE.md` and suggest slash commands for your specific workflow.

---

## Sync safety

If you use Obsidian Sync, iCloud, OneDrive, or Dropbox, **exclude** these paths from sync:

| Path | Why |
|------|-----|
| `.claude/` | Skills, logs, internal state — syncing can create a recursive feedback loop |
| `scripts/` | Python helpers that don't need to roam |
| `.env` | Contains your API key — never sync credentials |

**In Obsidian Sync:** Settings → Sync → Excluded folders → Add: `.claude`, `scripts`

---

## Requirements

| Tool | How to get it |
|------|--------------|
| Obsidian | `brew install --cask obsidian` (macOS) or `winget install Obsidian.Obsidian` (Windows) |
| Claude Code | `curl -fsSL https://claude.ai/install.sh \| sh` (macOS) or `winget install Anthropic.ClaudeCode` (Windows) |
| Python 3.8+ | [python.org](https://python.org) |
| Claude account | [claude.ai](https://claude.ai) — Pro recommended for heavy use |
