# Windows tester guide (Phase 1 beta)

A step-by-step for trying Noesis Starter on Windows and, optionally, bringing an
existing Obsidian vault into it. Written for the `setup.ps1` path.

## Read this first (honest state)

- This is a **fresh-install template**: it scaffolds a clean vault
  (`inbox/ daily/ projects/ research/ archive/`), installs 4 skills
  (`/vault-setup`, `/daily`, `/tldr`, `/file-intel`), and writes a starter
  `CLAUDE.md`.
- **Not in this version yet:** auto-augmenting an existing vault (you do it
  manually in Section 4), a real `research` module (sources/citations), and the
  deep "Power" interview (it is a stub; use **Basic**).
- **Windows is the more-tested path.** The macOS installer is still labeled beta.
- **Use a scratch folder, not your live vault.** The tool lays down a template;
  keep your real notes safe while you evaluate.

## 1. Before you start

The installer needs **git**, **native Windows python** (not WSL python),
**Claude Code (`claude`)**, and **Obsidian**. It will install any missing ones
via `winget`, Claude Code included. If you already have them, it skips those
steps. If it installs something via winget, you may need to close and reopen the
terminal before `claude` is on PATH.

**If you already run Claude Code with your own skills:** the installer copies its
4 skills into your **global** `%USERPROFILE%\.claude\skills\` (with overwrite), so
back yours up first:

```powershell
robocopy "$HOME\.claude\skills" "$HOME\.claude\skills.bak-prenoesis" /E
Copy-Item "$HOME\.claude\CLAUDE.md" "$HOME\.claude\CLAUDE.md.bak-prenoesis" -ErrorAction SilentlyContinue
```

If `daily`, `tldr`, `file-intel`, or `vault-setup` collide with skills you already
have, restore yours from the backup afterward.

## 2. Install (into a scratch vault)

```powershell
# Clone
git clone https://github.com/Noegnesis/noesis-starter
cd noesis-starter

# Prereq check only (installs nothing, just reports)
powershell -ExecutionPolicy Bypass -File setup.ps1 -Check

# Run the installer
powershell -ExecutionPolicy Bypass -File setup.ps1
```

It is a 7-step installer and will prompt you:

- **"Where should your second brain live?"** (default `C:\Users\<you>\noesis-vault`).
  Enter a scratch path instead, for example `C:\Users\<you>\noesis-scratch`. If you
  point at a folder that already looks like a vault, it warns "Existing vault
  detected" and asks **Continue? [Y/n]** first.
- **"Paste your Google API key"** - press **Enter to skip** (only needed for the
  `/file-intel` file-processing skill).
- **"Folder path to import"** - press **Enter to skip** (bring content in via
  Section 4 instead).
- **"Install Kepano's Obsidian skills? [Y/n]"** - choose **n** to keep your global
  config clean during the test (it also writes to global skills).

If winget shows a UAC prompt for a missing prereq, allow it. The installer creates
an isolated Python env at `%USERPROFILE%\.noesis-venv`.

## 3. Build and sanity-check the vault

```powershell
cd C:\Users\<you>\noesis-scratch
claude
```

Then in Claude Code:

1. Run **`/vault-setup`** and pick **Basic**. Answer the one "tell me about
   yourself" question.
2. At the context-loading question, choose **"Vault only"** to avoid editing your
   global `~/.claude/CLAUDE.md`. You can wire it global later.
3. Run **`/daily`** - it should create today's note and give a short briefing.
4. Drop a couple of files in `inbox/` and say *"Sort everything in inbox/ into the
   right folders."*

## 4. Bringing an existing vault in (optional)

You can build the scratch vault, then converge your existing notes into it. Do it
**additively** so nothing breaks.

**Golden rule:** copy, never move, from your real vault. Keep the original as a
backup until you are satisfied.

**Copy your content in (preserves your structure, so wikilinks stay intact):**

```powershell
# /E includes subfolders; /XD skips the scratch vault's own config + git
robocopy "C:\path\to\your-vault" "C:\Users\<you>\noesis-scratch" /E /XD .obsidian .git
```

Open `C:\Users\<you>\noesis-scratch` in Obsidian (Open folder as vault). You now
have your notes plus the workflow layer side by side.

**If you want to restructure** (move notes into `projects/ research/ archive/`),
do the moves **inside Obsidian** so internal links survive:

1. Settings -> Files & Links -> turn **ON** "Automatically update internal links".
2. Drag files in Obsidian's file explorer, or ask Claude to move them and then
   explicitly ask it to fix any `[[wikilinks]]` it broke. Moving files on the file
   system alone will not update links.

**Simplest augment-on-a-copy:** make a copy of your real vault, then run
`setup.ps1` pointed at the copy. The installer detects the existing vault, asks
before proceeding, and only adds the workflow layer. It does not touch your
existing notes or `.obsidian/`.

## 5. What to report back

- Did `setup.ps1 -Check` and the install run clean? Anything odd with winget,
  paths, or the venv?
- Did `/vault-setup` Basic and `/daily` work? What felt off?
- If you converged an existing vault, where did Section 4 get tedious or risky?
- Rough **token cost** of the onboarding run (matters for Claude Pro budgets).
- Anything that touched your existing Claude Code setup unexpectedly.

## 6. Safety summary

- Will **not** delete or edit your existing notes, and will **not** touch
  `.obsidian/`.
- **Will** back up an existing `CLAUDE.md` before writing a new one.
- **Will** add 4 skills to your global `%USERPROFILE%\.claude\skills\` (back these
  up first, Section 1).
- Re-runnable and idempotent. Creates an isolated `%USERPROFILE%\.noesis-venv`.
