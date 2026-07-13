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
- **Power (deeper, costs more tokens):** a guided modular interview — triage, pick the modules that fit, answer a few questions per module, and a deterministic assembler builds the vault. Best when you want more than the core spine.

Reply "basic" or "power".

---

If they pick **Power**, note: "Heads up — Power asks more questions and uses more tokens. On a Pro plan, Basic is usually plenty." Then follow **## Power branch — modular interview** below instead of STEP 1–5. The Basic branch (STEP 1–5) is unchanged.

## STEP 1 — One question, free text

**Tell me about yourself in a few sentences so I can build your vault.**

- What do you do for work?
- What falls through the cracks most — what do you wish you tracked better?
- Work only, or personal life too?
- Do you have existing files to import? (PDFs, docs, slides)

Answer these in whatever order feels natural. No need to be formal — a few sentences is enough.

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
- Windows: try `start "" "obsidian://open?path=<vault path>"`; if nothing opens, the manual step below covers it.
- Anything else: skip the auto-open.

If the vault path contains spaces, the auto-open URI may not resolve — the manual step always works.

Then always print:
```
If Obsidian did not open automatically:
  Obsidian -> Open folder as vault -> [absolute path of current folder]
```

### Write CLAUDE.md
Write a first-person `CLAUDE.md` with: `## Who I Am` (2-3 specific sentences from what they told you), `## My Vault Structure` (folder tree + one-line purpose each), `## How I Work` (3-4 inferred bullets), `## Context Rules` (decision -> which folder; person/project -> which folder; writing -> read recent daily notes; inbox -> ask to sort).

### Write skill files
- `.claude/skills/daily/SKILL.md`: read/create today's daily note (with a `## Linked Today` section), check `inbox/`, reconcile `## Linked Today` with any notes created today, surface top 3, ask what we're working on.
- `.claude/skills/tldr/SKILL.md`: summarize decisions / things to remember / next actions, save to the right folder, link the saved note under today's `## Linked Today`, update `memory.md`.
- Role skill (write a SKILL.md that does the described job): Business Owner -> `standup` (briefing across projects, decisions, people); Developer -> `project` (load a project's full context); Consultant -> `client` (load a client's full context); Creator -> `content` (read the content folder, calibrate voice, develop an idea); Student -> `research` (pull all notes on a topic and synthesize).

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
If global: append this to `~/.claude/CLAUDE.md` (create the file if needed):
```
## My Personal Context
At the start of every session, read [absolute vault path]/CLAUDE.md for context about who I am, my work, and my conventions.
```

## STEP 5 — Final output

```
Done. Your vault is ready.

If Obsidian is not open yet:
  Obsidian -> Open folder as vault -> [absolute path]

One manual step:
  Obsidian -> Settings -> General -> Enable Command Line Interface

Slash commands: /daily  /tldr  /[role]

Job hunting? Run /jobs-setup to stand up the job-search pipeline (optional).

Have files to import?
  python scripts/process_docs_to_obsidian.py ~/your-files inbox/
  Then: "Sort everything in inbox/ into the right folders"
```

## Power branch — modular interview

Run this instead of STEP 1–5 when the user chose **Power**. It drives the
deterministic engine that ships in the vault: `assemble.py` + `modules/*.md`
(schema in `modules/README.md`). You never hand-build folders or hand-write
folder rules here — the assembler owns them.

### P1 — Triage (3–4 questions)

Ask, in one turn:
- What do you do, and what are you trying to keep track of?
- Work only, or personal life too?
- Do you keep a journal / write reflections?
- Do any of these fit: tracking sources for papers or a literature review; a
  portfolio of finished work; **an active job search**?

If they say **job search**, tell them: "The job pipeline is its own module —
finish this vault, then run **/jobs-setup** to stand it up." Do not add a jobs
module here.

### P2 — Select modules

Read every `modules/*.md`. Each doc's frontmatter has `id`, `tier`, `default`,
`suggests`; its `## Applies when` line says when to offer it. Build the
selection:
- Pre-check every module with `default: true` (the core spine: inbox, daily,
  projects, research, archive). `people` is `default: false` — offer it if the
  triage mentioned relationships, clients, a team, or networking.
- Offer each `persona` module whose `## Applies when` matches the triage
  (journal-reflection, research-augment, asset-portfolio). When the user picks
  one, also surface (don't auto-select) anything in its `suggests`.

Show the proposed module list and let them add/remove before continuing.

### P3 — Per-module questions

For each selected module, in dependency order, ask its `## Questions` bullets
(`key — prompt (default: value)`). One module at a time. Skip a module that has
no questions. Record answers keyed by module id.

### P4 — Write the answers file

Write the answers to `.noesis/answers.yaml` in the vault, nested by module id
(see `modules/README.md` → "Answers file"), e.g.:

```yaml
inbox:
  sort_cadence: weekly
journal-reflection:
  reflection_cadence: weekly
```

Omit any answer the user left at its default — the assembler falls back to the
question's `(default: ...)`.

### P5 — Preview (dry-run) and gate

Run the assembler in dry-run (default — writes nothing):

```bash
python assemble.py --select <ids,comma-separated> --answers .noesis/answers.yaml --dest .
```

Show the printed plan (folders, seeds, and the CLAUDE.md managed-region
preview). Then wait: **"Type 'build it' to create this, or tell me what to
change."**

### P6 — Build

On "build it", re-run with `--execute`:

```bash
python assemble.py --select <ids,comma-separated> --answers .noesis/answers.yaml --dest . --execute
```

The assembler creates folders, writes seeds (never overwriting), and writes the
CLAUDE.md **managed region** between `<!-- noesis:modules:start -->` /
`<!-- noesis:modules:end -->`. An existing CLAUDE.md is backed up first and only
the managed region is touched.

### P7 — Identity prose (no duplication)

The managed region already carries every folder and context rule (it is
assembled from the module snippets). Your only CLAUDE.md job now is the
**identity** the modules can't know: add a `## Who I Am` section (2–3 specific
sentences from the triage) **above** the `<!-- noesis:modules:start -->` marker.
Do **not** restate folder purposes or context rules outside the region — those
live in the managed region, and repeating them is the duplication this branch
exists to avoid.

### P8 — Finish

Open the folder as a vault (same OS-detection + manual fallback as Basic STEP 3:
macOS `open -a Obsidian`, Windows `start`/explorer, Linux `xdg-open`; always
print "Obsidian → Open folder as vault → [absolute path]"). Then do STEP 4
(context injection) and STEP 5 (final output) as written. If the triage flagged
a job search, remind them: "Run **/jobs-setup** to stand up the job pipeline."
