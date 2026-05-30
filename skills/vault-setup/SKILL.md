---
name: vault-setup
description: Interactive Obsidian vault configurator. Interviews you in free text, then builds a personalized vault, CLAUDE.md, and slash commands in the current folder. Offers a fast Basic build or a deeper Power build.
---

# Vault Setup — Obsidian Configurator

Run from INSIDE the folder you want to become your Obsidian vault.

## STEP 0 — Choose a path

Display this, then wait:

---

**How deep do you want to go?**

- **Basic (recommended, fast, low token cost):** a few questions, a clean core vault you can grow into. Best on a Pro plan.
- **Power (deeper, costs more tokens):** a longer interview that tailors the vault to how you specifically work.

Reply "basic" or "power".

---

If they pick **Power**, note: "Heads up — Power asks more questions and uses more tokens. On a Pro plan, Basic is usually plenty." Then continue; the deep modular interview ships in a later version, so for now run the Basic flow but ask 2-3 extra tailoring questions.

## STEP 1 — One question, free text

**Tell me about yourself in a few sentences so I can build your vault.**

- What do you do for work?
- What falls through the cracks most — what do you wish you tracked better?
- Work only, or personal life too?
- Do you have existing files to import? (PDFs, docs, slides)

A few sentences is enough.

## STEP 2 — Infer and preview (don't ask more)

From their answer infer role, primary pain point, scope, and whether they have files. Show a preview:

```
Here's your vault — ready to build when you are.

[current directory name]
  inbox/      Drop zone — everything new lands here first
  daily/      Daily brain dumps and quick captures
  [folder]/   [purpose based on their role]
  projects/   Active work with status and next actions
  archive/    Completed work — never deleted, just moved

Slash commands: /daily  /tldr  /[role]

Type "build it" to create this, or tell me what to change.
```

Wait for confirmation.

Role folder sets: Business Owner -> `people/ operations/ decisions/`; Developer -> `research/ clients/`; Consultant -> `clients/ research/`; Creator -> `content/ research/ clients/`; Student -> `notes/ research/`. Personal scope -> also `personal/`.

## STEP 3 — Build after confirmation

### Create folders
```bash
mkdir -p inbox daily [role folders] projects archive scripts \
  .claude/skills/daily .claude/skills/tldr .claude/skills/[role-command]
```

### Back up any existing CLAUDE.md, then open the vault
Before writing CLAUDE.md, if one already exists, copy it to `CLAUDE.md.bak.<timestamp>` so nothing is lost.

Open the folder as a vault. Detect the OS and run the right command, and ALWAYS print the manual step so it can never silently fail:

- macOS: `open -a Obsidian "<vault path>"`
- Linux: `xdg-open "obsidian://open?path=<vault path>"`
- Windows / anything else: skip the auto-open.

Then always print:
```
If Obsidian did not open automatically:
  Obsidian -> Open folder as vault -> [absolute path of current folder]
```

### Write CLAUDE.md
Write a first-person `CLAUDE.md` with: `## Who I Am` (2-3 specific sentences from what they told you), `## My Vault Structure` (folder tree + one-line purpose each), `## How I Work` (3-4 inferred bullets), `## Context Rules` (decision -> which folder; person/project -> which folder; writing -> read recent daily notes; inbox -> ask to sort).

### Write skill files
- `.claude/skills/daily/SKILL.md`: read/create today's daily note, check `inbox/`, surface top 3, ask what we're working on.
- `.claude/skills/tldr/SKILL.md`: summarize decisions / things to remember / next actions, save to the right folder, update `memory.md`.
- Role skill: Business Owner -> `standup`; Developer -> `project`; Consultant -> `client`; Creator -> `content`; Student -> `research`.

### Write memory.md
```markdown
# Memory

## Session Log
[Updated after each session]

## My Preferences
[Added as Claude learns them]
```

## STEP 4 — Context injection question

```
How do you want your vault context loaded into Claude Code?
1. Global (recommended) — one line in ~/.claude/CLAUDE.md, loads every session on this machine
2. Manual — I give you the line to paste per project
3. Vault only — works when you run claude from inside this folder
```
If global: append to `~/.claude/CLAUDE.md` (create if needed) a `## My Personal Context` line pointing at `[absolute vault path]/CLAUDE.md`.

## STEP 5 — Final output

```
Done. Your vault is ready.

If Obsidian is not open yet:
  Obsidian -> Open folder as vault -> [absolute path]

One manual step:
  Obsidian -> Settings -> General -> Enable Command Line Interface

Slash commands: /daily  /tldr  /[role]

Have files to import?
  python scripts/process_docs_to_obsidian.py ~/your-files inbox/
  Then: "Sort everything in inbox/ into the right folders"
```
