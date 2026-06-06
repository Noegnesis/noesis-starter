# Repo Convergence: absorb second-brain-onboarding into noesis-starter

- **Date:** 2026-06-06
- **Status:** Approved (design review complete)
- **Repos:** [noesis-starter](https://github.com/Noegnesis/noesis-starter) (canonical, survives) · [second-brain-onboarding](https://github.com/Noegnesis/second-brain-onboarding) (absorbed, archived)

## Context

`second-brain-onboarding` (SBO) is a standalone, anonymized guide repo: 8 branching docs, an
Obsidian-flavored source copy (`obsidian-source/`), and a converter (`tools/convert.py`) that
generates GitHub-flavored `docs/` from it. Last meaningful push: 2026-05-24.

`noesis-starter` forked those 8 docs into its own `docs/` around 2026-05-30 and evolved them
forward: paths rewritten from the original author-specific folder taxonomy to the starter's
generic one (`inbox/`, `daily/`, `projects/`, …), a Notebook Navigator setup section, a
plugin-install how-to, plus net-new docs SBO never had (`docs/advanced/` ×4,
`augmenting-an-existing-vault.md`, `docs/handoff/` ×2).

**Problem:** two divergent copies of the same guide are a permanent drift tax (one week of
divergence already accrued), and SBO's best qualities — its README-as-onboarding-experience and
its read-the-guide-in-your-vault idea — never made it into the starter.

**Decisions locked during design review:**

1. Primary audience for the merged repo is **fresh users being onboarded** → the installer stays
   the README's front door; the guide is the depth layer.
2. SBO has been **shared with a few people** → archive with a pointer README so the URL stays
   alive; do not delete.
3. Key simplification: GitHub's five alert types (`[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`,
   `[!WARNING]`, `[!CAUTION]`) are all valid Obsidian callouts, and Obsidian resolves relative
   markdown links and renders Mermaid. **One GitHub-flavored doc set renders correctly in both
   GitHub and Obsidian** — no converter, no dual source.

## Design

### 1. Repo fates

- **noesis-starter** — canonical home; all changes below land here.
- **second-brain-onboarding** — replace README with a short pointer (the guide moved to
  noesis-starter and kept evolving there; start at `docs/README.md`), keep LICENSE, then archive
  the repo on GitHub (read-only + banner). Nothing is deleted.

### 2. Guide front door: `docs/README.md`

New file, ported from SBO's README and updated for the current doc set:

- The 60-second mental model (capture → triage → retrieve → reflect, Mermaid).
- The four persona paths with reading orders: Weekend Minimalist, Researcher, ADHD-First
  Builder, Power User / Tinkerer.
- The router decision tree (Mermaid).
- Full doc index table — now including `docs/advanced/` (typed memory, MCP wiring, agent
  system, ADHD patterns) and `augmenting-an-existing-vault.md`. The Power User path points
  into `advanced/`.
- The glossary (collapsible).
- A provenance footer noting the guide's lineage from second-brain-onboarding.

The top-level `README.md` keeps Quick Start first and gains one prominent section linking to
the guide: "📚 The full guide — pick your path → docs/README.md".

### 3. Restore alerts in the 8 core docs

Diff each of the 8 docs against SBO's copies at HEAD (`026fdbd`) and re-add the `> [!TIP]` / `> [!WARNING]` / `> [!NOTE]` markers the fork
dropped — **keeping all of noesis-starter's newer prose**. Formatting recovery only; no content
changes. Where SBO used Obsidian-only callout types, map per SBO's own `ALERT` table
(e.g. `success`→`TIP`, `danger`→`CAUTION`) or fall back to a bold-titled blockquote.

### 4. Guide ships inside the vault it creates

New step in both `setup.sh` and `setup.ps1`:

- Prompt: "Include the full guide in your vault? [Y/n]" — default **yes**.
- On yes: copy `docs/` → `<vault>/guide/`, excluding `handoff/` (tester-facing, not
  user-facing), plus a hand-maintained `guide/MOC - Guide.md` (adapted from SBO's MOC, using
  relative markdown links — Obsidian's graph view picks those up).
- On copy failure: print the manual copy command and continue — consistent with the
  installer's existing non-destructive, print-the-manual-step philosophy.
- `CLAUDE.md` template's vault-structure block gains one line for `guide/`.

Single-source rule: `docs/` is the only canonical copy. The vault copy is a generated artifact;
to refresh it, re-run setup or re-copy. Nothing in `guide/` is ever hand-edited as a source.

### 5. Tests

- `test_docs.sh` — extend: every relative link in `docs/` (including `docs/README.md`)
  resolves to a real file; every alert marker is one of the five GitHub types.
- `test_readme.sh` — extend: `docs/README.md` exists; persona-path links resolve.
- Setup/vault assertions — `guide/` lands in the created vault with the MOC present;
  `handoff/` is excluded.
- `test_no_personal_data.sh` — already repo-wide; ported SBO content must pass the denylist.

### 6. Retired, not ported

- `obsidian-source/` — superseded by the single-format `docs/`.
- `tools/convert.py` — no longer needed (see decision 3).
- SBO's stale doc copies — noesis-starter's versions are strictly newer.

## Non-goals

- No backporting of noesis-starter improvements into SBO (it freezes at the pointer).
- No repo rename and no new umbrella repo.
- No converter or sync machinery between formats or repos.
- No restructuring of the guide's content itself (prose edits are out of scope).

## Acceptance criteria

1. `docs/README.md` exists with paths, router, index (incl. advanced docs), glossary.
2. Top-level README links to it; Quick Start remains the first section.
3. All 8 core docs use GitHub alert syntax where SBO had callouts; no prose lost.
4. Fresh setup run (both platforms) produces `<vault>/guide/` with MOC; opt-out works.
5. Full test suite green, including new assertions.
6. SBO shows pointer README and is archived (read-only) on GitHub.
