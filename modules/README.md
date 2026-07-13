# modules/ — the noesis module engine

One markdown doc per module: **add a module = add a file.** `assemble.py`
validates every doc against this schema (`python assemble.py --validate`),
and the /vault-setup Power branch drives its interview from these docs.

## Frontmatter (YAML)

- `id` — kebab-case, MUST match the filename (without `.md`)
- `tier` — `core` | `persona` | `advanced`
- `title` — display name used in the interview and the CLAUDE.md region
- `depends_on` — list of module ids pulled in automatically (cycles are errors)
- `suggests` — list of module ids the interview surfaces (not auto-selected)
- `default` — bool; pre-checked in the interview

## Body sections (H2, this order)

Required:
- `## Concept` — one paragraph: what this module is for.
- `## Applies when` — one line the interview's triage uses to decide whether to offer it.
- `## Questions` — zero or more bullets, one per question:
  `- key — prompt (default: value)` (em-dash separator). Answers fill
  `{{key}}` placeholders in seeds and the CLAUDE.md snippet.
- `## Creates` — bullets: `- folder/` (trailing slash = folder) or
  `- path/file.md — one-line description` (a seed file; if the very next line
  opens a fenced block, that block is the seed's `{{key}}`-templated content,
  otherwise the seed gets `# <description>` as content).
- `## CLAUDE.md snippet` — one fenced block, `{{key}}`-templated; assemble.py
  concatenates snippets in dependency order inside the managed region of the
  vault's CLAUDE.md.

Optional:
- `## Slash commands` — skills this module wants installed (informational;
  assemble.py never touches `~/.claude`).
- `## Files` — the payload: `- ` + backticked repo path, optionally
  ``` → `vault/dest/path` ``` for an explicit destination. Every source path
  is machine-checked to exist in the repo.
- `## Memory rules` — bullets appended after the snippet in the managed region.

## Answers file

`assemble.py --answers` takes YAML nested by module id:

```yaml
inbox:
  sort_cadence: weekly
daily:
  daily_focus: top 3 priorities
```

Missing keys fall back to the question's `(default: ...)`; a key with no
answer and no default is a named error.
