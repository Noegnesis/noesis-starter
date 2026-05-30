# Advanced: Typed memory (optional)

Give the agent a structured memory schema so it recalls the right things in the right contexts — without re-learning from scratch each session.

## The idea

The default `memory.md` is a flat list. Typed memory adds a frontmatter `type:` field to each memory file and a lightweight index, so the agent can route by category instead of scanning everything:

```yaml
---
type: user          # who-you-are facts (role, preferences, working style)
type: feedback      # corrections and behavioral updates
type: project       # per-project state (deadline, last decision, blockers)
type: reference     # stable lookup facts (course codes, tool paths, people)
---
```

## Why it helps

- The agent loads only the memory files relevant to the current task rather than dumping the whole index into context.
- It's easier to audit: "show me all `project` memories that are older than 30 days" is a tractable maintenance task.
- Contradictions are easier to spot (two `reference` files saying different things about the same path).

## How to adopt it

1. Add a `type:` frontmatter field to each memory file.
2. Update `MEMORY.md` to include a one-line summary + the type for each entry.
3. Add a routing rule to `CLAUDE.md`: *"When working on a project, load only `project`-type memories and the relevant `reference` entries."*
4. Prune or merge memories that are duplicated or stale.

This is opt-in and additive — existing flat memories still work. Migrate incrementally.

(A guided setup is planned for a later version of this tool.)
