---
title: 06 — ADHD Empowerment System
tags:
  - setup
  - onboarding
  - adhd
  - executive-function
---

# 06 — ADHD Empowerment System

> **In one breath**
> If your challenge isn't *knowing what to do* but *starting, remembering, and sequencing* it, a second brain can carry the executive functions that fail under load. This doc reframes the whole stack as a set of **prosthetics for executive function**: making deadlines impossible to miss, making starting trivially easy, and making the system forgiving when discipline runs out.

← [Start Here](../README.md) · prev [05 — Skills & Automation](05-skills-and-automation.md)

---

## The reframe: tools as prosthetics, not discipline

Most productivity advice assumes the bottleneck is *knowledge* or *willpower*. For ADHD (and for anyone under heavy load), the bottleneck is usually **executive function** — the brain's ability to prioritize, initiate, sequence, hold things in mind, and resist distraction. Those are exactly the functions that degrade first.

A second brain works here because it **externalizes** those functions:

| Executive function that fails | What the system does instead |
|---|---|
| Remembering deadlines | Surfaces them in a daily briefing — you can't forget what's in front of you |
| Prioritizing | Picks a top 3, so you don't face an undifferentiated pile |
| Task initiation ("I can't start") | Breaks the next step into something *absurdly* small |
| Working memory | Holds everything so you don't have to |
| Self-monitoring | Audits itself for drift and stale state |

> [!TIP]
> **Design principle for this whole doc**
> Don't build a system that requires you to be disciplined to use it. Build one that **works even on your worst day** — and rewards, rather than punishes, the days you fall off.

---

## Pattern 1 — Capture must beat avoidance

Avoidance lives in friction. If capturing a thought requires a decision ("where does this go?"), the ADHD brain will often just… not. So:

- **One inbox, zero decisions.** Everything to `inbox/`. No categorizing at capture. (Principle #1, [01 — Foundations & Philosophy](01-foundations-and-philosophy.md).)
- **Capture from wherever you are.** The thought you have on a walk is worth nothing if saving it requires opening a laptop. Voice capture matters (Pattern 5).
- **Triage is a separate, low-stakes ritual** — done with the agent, often: "want me to sort the inbox?" Sorting *something else's* mess is far easier than sorting at the moment of capture.

---

## Pattern 2 — Make deadlines impossible to miss

> Deadlines don't slip because you don't care. They slip because **you don't see them daily.**

The fix is the morning briefing ([/daily](05-skills-and-automation.md)): every morning, the agent surfaces today's open tasks and what's coming due — pulled from your vault (and from connected services only if you've wired them — optional; see [docs/advanced/mcp-wiring.md](advanced/mcp-wiring.md)), dropped into one note you actually open. The deadline you see every morning is the deadline you meet.

```
Calendar + tasks + notes
  → /daily briefing
     → You SEE it every morning
        → It gets done
```

Pair it with a weekly review ([/weekly](05-skills-and-automation.md)) so nothing falls through the gap between days. (Note: `/weekly` is not in the starter set — build it with the skill-authoring pattern in [05 — Skills & Automation](05-skills-and-automation.md).)

---

## Pattern 3 — The smallest-next-step rule

The single most ADHD-aware behavior to bake into your agent (via [CLAUDE.md](03-the-agent-layer-claude-code.md)):

> [!IMPORTANT]
> **Put this in your CLAUDE.md**
> *"When I seem stuck or avoidant, offer the smallest possible next action — not a plan."*

A plan is overwhelming; it's ten decisions stacked up. A single, tiny, concrete next action ("open the file and write one sentence") bypasses the initiation barrier. Once you're moving, momentum does the rest. The agent's job in your worst moments isn't to organize your week — it's to get you to do *one* thing.

> **The difference in practice**
> **Overwhelming:** "Here's a 6-step plan to finish your application."
> **Empowering:** "Just open the doc and paste your notes in. That's the whole task right now."

---

## Pattern 4 — Gamify the boring upkeep

Habit maintenance is dopamine-poor, which is exactly why it's hard. Wiring the vault to a **gamification layer** (a habit/task RPG, e.g. Habitica) converts dailies and habits into XP, levels, and streaks — an external reward loop that the ADHD brain responds to.

- Dailies (journal, review, exercise) become tracked tasks with rewards.
- The agent reads/writes them, so "what are my dailies?" and "mark journaling done" happen in the same place you already work.
- Streaks create *just enough* loss-aversion to keep the loop alive without becoming a guilt machine.

> [!TIP]
> **Keep it kind**
> Gamification should reward action, not punish lapses. If a streak-break makes you abandon the whole system, the system is too brittle. Tune for "easy to restart," not "expensive to break."

---

## Pattern 5 — Voice capture beats the blank page

The blank page is an initiation wall. Talking is not. A voice-capture pipeline removes the wall:

```
Voice memo on phone
  → Transcription
     → Appended to journal as raw text
        → Agent can summarize LATER — never overwrites the raw
```

- Speak a thought → it's transcribed → it lands in your journal as a `> [!raw]` block (your voice, AI-untouched — see [01 — Foundations & Philosophy](01-foundations-and-philosophy.md) principle #5).
- The *content* gets captured even when sitting down to type feels impossible.
- The agent can later clean or summarize it — but the raw transcript is never destroyed, so you can always hear your real, unfiltered self.

This is also why the **identity layer** (`identity/`) has its own protected home: reflections and journal are where motivation actually lives, and they must feel safe and un-judged to be useful.

---

## Pattern 6 — A forgiving, self-healing system

ADHD means you *will* fall off. The system has to survive that:

- **Never delete, only archive.** Falling behind never destroys anything. You can always pick back up.
- **State is recoverable.** Daily/weekly notes reconstruct "where was I?" so returning after a gap isn't a cold start.
- **The agent re-orients you.** "I've been away for two weeks, what did I drop?" is a question the system can answer from its own notes.
- **Self-audit** ([07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md)) catches drift so a lapse in upkeep doesn't quietly rot the system.

> [!TIP]
> **The forgiveness test**
> Imagine ignoring the system for a month. Can you return in 10 minutes and know exactly where you are? If yes, it's ADHD-proof. If returning feels like starting over, simplify until it doesn't.

---

## Pattern 7 — Anchor to *why*, not just *what*

Pure task systems fail the ADHD brain because tasks alone aren't motivating. The **identity/reflection layer** keeps the "why" visible: what you're working toward, what matters, who you're becoming. When discipline fails, purpose is what restarts the engine. Keep that layer close, protected, and in your own voice — it's the anchor the whole productivity system hangs from.

---

## Assembling the system

| Pattern | Built with |
|---|---|
| Frictionless capture | `inbox/` + voice pipeline ([02 — Obsidian Vault Setup](02-obsidian-vault-setup.md)) |
| Deadline surfacing | `/daily` + `/weekly` ([05 — Skills & Automation](05-skills-and-automation.md)) |
| Smallest next step | A CLAUDE.md rule ([03 — The Agent Layer (Claude Code)](03-the-agent-layer-claude-code.md)) |
| Gamified upkeep | A habit-RPG integration ([04 — Connectors & Tools (CLI → API → MCP)](04-connectors-and-tools.md)) |
| Voice capture | Transcription → raw journal ([02 — Obsidian Vault Setup](02-obsidian-vault-setup.md)) |
| Forgiveness | Archive-don't-delete + self-audit ([07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md)) |
| Purpose anchor | The protected identity layer |

---

## What "done with this doc" looks like

- [ ] The smallest-next-step rule is in your CLAUDE.md
- [ ] `/daily` surfaces deadlines you'd otherwise miss
- [ ] Capture has near-zero friction (and ideally a voice path)
- [ ] The system passes the *forgiveness test* — you can return after a lapse without starting over

If you only build the patterns in this doc, you have a system that carries you on the days you can't carry yourself. To keep it healthy across devices and over time, continue to [07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md).

---
← [05 — Skills & Automation](05-skills-and-automation.md) · next → [07 — Sync, Devices & Maintenance](07-sync-devices-and-maintenance.md)
