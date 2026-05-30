# Advanced: ADHD-friendly patterns (optional)

Low-friction capture, externalizing the next action, and gentle nudges — a deeper cut on the patterns introduced in [06 — ADHD Empowerment System](../06-adhd-empowerment-system.md).

## These are opt-in layers, not requirements

The core stack already has ADHD support baked in: one inbox, `/daily` deadline surfacing, the smallest-next-step rule. This doc adds *additional* patterns for people who want to go further. Add them one at a time; evaluate after a week; drop anything that adds friction rather than removing it.

---

## Pattern: The "good enough to capture" threshold

Lower the quality bar for what counts as a valid note. A half-formed thought, a single sentence, a voice memo transcript with typos — all valid. The rule: **if it costs less than 10 seconds to capture, capture it**. The agent can triage and improve later.

Add this to your `CLAUDE.md`:
> *"When I capture something rough, don't ask me to refine it at capture time. File it as-is and ask later, during triage."*

---

## Pattern: Externalize the "what next" for every project

For every active project, keep a single line at the top of its notes file:

```markdown
## Next action
Open the draft and add the missing section heading.
```

The agent updates this line at the end of every session. You never have to reconstruct "where was I?" — the answer is always in the first line. This is the smallest-next-step rule ([06 — ADHD Empowerment System](../06-adhd-empowerment-system.md) Pattern 3) applied at the file level.

---

## Pattern: Gentle nudges via hooks

Use a Claude Code hook to surface a gentle reminder at session start:

- If today's daily note hasn't been opened yet → "Start with `/daily`?"
- If the inbox has more than N files → "Your inbox has X items — want me to triage?"
- If a project's next-action line hasn't been updated in 3+ days → "Looks like [Project] hasn't moved — is it stuck?"

These are nudges, not alarms. They should feel like a helpful prompt from a colleague, not a guilt machine. If a nudge starts feeling bad, turn it off.

---

## Pattern: The "return protocol"

Coming back after days or weeks away is one of the highest-friction moments. An explicit return protocol removes the cold-start overhead:

1. Open Claude Code and type: "I've been away for [N days/weeks]. What should I know?"
2. The agent reads: today's daily note, the last weekly review, open project next-actions, and recent inbox items.
3. It surfaces: the top 3 things that moved while you were away, any deadlines that became urgent, and the single best place to start.

Add this as a skill (`/return`) so you don't have to remember the protocol — just type the verb.

---

## Pattern: Forgiveness-first design

Every system choice should pass the forgiveness test: *"If I ignore this for a month, can I pick it back up in 10 minutes?"*

- Folders: archive-don't-delete, so nothing is ever destroyed.
- Tasks: a next-action line that the agent can update, so re-entry is one read.
- Habits: streaks that forgive a single miss, so a bad day doesn't cascade.
- Memory: periodic notes that reconstruct "where was I?" from first principles.

Review your system against this test quarterly. Anything that fails it — that makes return painful — simplify or remove.

(A guided ADHD configuration interview is planned for a later version of this tool.)
