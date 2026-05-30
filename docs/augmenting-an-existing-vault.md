# Augmenting an existing vault

You already have an Obsidian vault you care about — research notes, a project
system, years of writing. This guide adds the Noesis workflow layer (the skills,
daily-note flow, and folder conventions) **without** risking your notes, your
`[[wikilinks]]`, or your existing Claude Code setup.

Works on **Windows** and **macOS** (parallel commands throughout). The macOS
*installer* is still labeled beta; the manual copy commands here (`rsync`, `cp`)
are standard and safe on any Mac.

> **Best way to use this guide:** paste it into Claude Code inside your vault and
> say *"walk me through augmenting this vault."* Claude will ask the triage
> questions below and guide you one step at a time. The rest of this doc is what
> Claude (and you) follow.

---

## Two ways in — let Claude triage

Before any commands, answer three questions (Claude should ask these):

1. **Is your vault backed up?** Under git, or syncing to iCloud / Dropbox /
   Google Drive? → If **yes**, in-place is safe. If **no**, set up a backup
   first, or use the on-a-copy path.
2. **Do you run your own Claude Code skills or global `CLAUDE.md`?** → If yes,
   you'll back up `~/.claude/skills` first (one command, applies to both paths).
3. **Do you want to evaluate first, or commit directly?** → "Try it safely" →
   on-a-copy. "Just add it to my vault" → in-place.

| | **Path A — In-place** | **Path B — On a copy** |
|---|---|---|
| What it does | Adds the layer to your real vault | Copies your vault, augments the copy |
| Moves your notes? | No — only *adds* folders | No |
| Best when | Vault is backed up (git/cloud) | You want try-before-you-trust |
| Effort | Lowest | Copy step + adopt step |

**Recommendation:** if your vault is under version control or cloud sync, use
**Path A** — it's less moving around and the installer is purely additive. Reach
for Path B only when you can't confirm a backup or want to evaluate in isolation.

---

## Before you touch anything (both paths)

**1. Confirm your vault backup exists.** In-place is safe, but a backup is your
undo button. If your vault is a git repo: `git status` should be clean and pushed.

**2. Back up your global Claude Code skills.** The installer overwrites four skill
names in your **global** skills folder (`vault-setup`, `daily`, `tldr`,
`file-intel`) with `--Force`. If you have your own skills by those names, save
them first:

```powershell
# Windows
robocopy "$HOME\.claude\skills" "$HOME\.claude\skills.bak-prenoesis" /E
Copy-Item "$HOME\.claude\CLAUDE.md" "$HOME\.claude\CLAUDE.md.bak-prenoesis" -ErrorAction SilentlyContinue
```

```bash
# macOS
cp -R ~/.claude/skills ~/.claude/skills.bak-prenoesis
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak-prenoesis 2>/dev/null || true
```

(The global `CLAUDE.md` backup is belt-and-suspenders — see *Protect your Claude
Code setup* below for why it's usually not at risk.)

---

## Path A — Augment in place

1. Do the backups above.
2. Run the installer and point it at **your real vault path**:

   ```powershell
   # Windows
   git clone https://github.com/Noegnesis/noesis-starter; cd noesis-starter
   powershell -ExecutionPolicy Bypass -File setup.ps1
   ```

   ```bash
   # macOS
   git clone https://github.com/Noegnesis/noesis-starter && cd noesis-starter
   bash setup.sh
   ```

3. At **"Where should your second brain live?"**, enter your existing vault path.
   It detects the vault and shows **"Existing vault detected → Continue? [Y/n]"**.
   On continue it will:
   - **Add** `inbox/ daily/ projects/ research/ archive/`, `scripts/`,
     `memory.md`, and a vault-local `.claude/skills/`.
   - **Back up** your existing `CLAUDE.md` → `CLAUDE.md.backup-<timestamp>`, then
     write a fresh template.
   - **Install** the four skills globally (overwrite — that's why you backed up).
   - **Leave untouched**: every existing note (including anything already in
     `inbox/`, `daily/`, etc.) and your entire `.obsidian/` (plugins, themes,
     settings).
4. At **"Folder path to import"**, press **Enter to skip** — your content is
   already in place.
5. At **"Install Kepano's Obsidian skills?"**, your call (it also writes to global
   skills; choose **n** to keep global config lean).
6. **After it finishes**, open your old `CLAUDE.md.backup-<timestamp>` and merge
   any conventions you want to keep into the new template, then re-run
   `/vault-setup` to personalize.

> **About the new top-level folders:** the installer *adds* `inbox/`, `research/`,
> etc. to your vault root. If your research vault already has its own structure,
> that's fine — the new folders are empty; keep the ones you like, delete the rest.
> Nothing is forced and nothing existing is moved.

---

## Path B — Augment on a copy (safest to evaluate)

1. Do the backups above.
2. **Copy your whole vault** to a scratch folder. Keep `.obsidian/` so your
   plugins and settings come along:

   ```powershell
   # Windows — /E recurses; drop only git history into the copy
   robocopy "C:\path\to\your-vault" "C:\Users\<you>\noesis-scratch" /E /XD .git
   ```

   ```bash
   # macOS — trailing slashes matter; exclude only .git
   rsync -av --exclude='.git' ~/path/to/your-vault/ ~/noesis-scratch/
   ```

3. Run the installer (commands as in Path A) and point it at the **scratch copy**.
   Same prompts, same additive behavior — your original is never touched.
4. Open the scratch vault in Obsidian (*Open folder as vault*), evaluate the
   workflow, run `/daily`.
5. **Adopt when happy:** simplest is to make the scratch copy your working vault
   going forward. (Your original remains as a frozen backup.)

---

## Restructuring notes safely (optional, either path)

If you reorganize notes into `projects/ research/ archive/`, keep your wikilinks
intact:

1. Obsidian → **Settings → Files & Links → "Automatically update internal links" ON**.
2. Move files **inside Obsidian** (drag in the file explorer) — *not* in
   Explorer/Finder. OS-level moves do **not** update `[[wikilinks]]`.
3. If you ask Claude to move files, also tell it to **fix any wikilinks it broke** —
   moving on the filesystem alone leaves links dangling.

---

## Protect your Claude Code setup (power-user tier)

If you run a custom Claude Code stack — your own skills, agents, or a
multi-instance setup — here is exactly what the installer touches and what it
doesn't:

- **Overwrites global skills.** `~/.claude/skills/{vault-setup,daily,tldr,file-intel}/SKILL.md`
  are replaced with `--Force`. This is the **only** thing that reaches your global
  config. Back up `~/.claude/skills` first (above); after install, restore any of
  those four that collided with skills of yours.
- **Backs up your vault `CLAUDE.md`.** The *vault-local* `CLAUDE.md` is saved to
  `CLAUDE.md.backup-<timestamp>` before the template is written. Nothing is lost.
- **Does NOT touch your global `~/.claude/CLAUDE.md`.** The installer never writes
  there. It's only at risk *later* if you run `/vault-setup` and choose to load
  context globally — at that prompt, choose **"Vault only"** to keep your global
  config untouched.
- **Everything else is vault-local.** Folders, `scripts/`, `memory.md`, and the
  vault's `.claude/skills/` all live inside the vault and don't affect your other
  projects.

---

## Verify nothing broke

- Open the vault in Obsidian; click a `[[wikilink]]` — it resolves.
- Your community plugins still load (Notebook Navigator, etc.).
- Your own global skills survived: `ls ~/.claude/skills` (Win:
  `Get-ChildItem $HOME\.claude\skills`).
- **Path A:** `git diff --stat` in your vault shows **only additions** plus the
  `CLAUDE.md` backup — no edits to existing notes.
- **Path B:** `git status` in your **original** vault is clean (you never touched it).
- Run `/daily` — it creates today's note and gives a short briefing.

---

## Honest state (Phase 1)

- **Auto-augment isn't built yet** — this is the manual path. The installer adds
  the workflow layer; convergence and restructuring are hands-on (Claude helps).
- **No real research module yet** — you get a `research/` folder and can ask Claude
  to scaffold a research MOC, but there's no citation/source engine. That's Phase 2.
- **macOS installer is beta** (verifying on hardware). The manual copy commands
  (`rsync`, `cp`) above are standard Unix and safe regardless.

---

## Safety summary

- **Never** deletes or edits your existing notes; **never** touches `.obsidian/`.
- **Backs up** your vault `CLAUDE.md` before replacing it.
- **Overwrites** four global skills — back up `~/.claude/skills` first.
- **Idempotent and re-runnable**; uses an isolated `~/.noesis-venv`.
- **Path B** leaves your original vault frozen as a backup.

---

## See also

- [Community plugins & Notebook Navigator setup](02-obsidian-vault-setup.md#step-5--plugins-only-what-earns-its-keep)
  — recommended plugins and how to have Claude configure NN for your use cases.
- [Windows tester guide](handoff/windows-tester.md) — beta-test checklist.
