# Advanced: Agent system (optional)

Route inputs to specialized helper skills rather than handling everything in one monolithic agent. This is advanced — build it only after your core skills are solid and you're hitting real coordination limits.

## The idea

A single agent handles most second-brain tasks well. At larger scale — many skills, multiple input sources (vault, phone, desktop), complex multi-step workflows — you can split responsibilities:

- **A monitor agent** watches for incoming inputs and routes them.
- **Specialist agents** handle specific domains (research synthesis, calendar management, inbox triage).
- **A handshake protocol** lets agents hand off context between each other without losing state.

## When to consider it

- You have 10+ skills and the agent regularly picks the wrong one.
- You want to process inputs from multiple sources (vault + phone + email) in parallel.
- A workflow is long enough that a single context window fills before it completes.

Most people never need this. A flat set of well-named skills with clear SKILL.md trigger descriptions handles the vast majority of second-brain workflows.

## Prerequisites

Before building a multi-agent system:
1. All your core skills work reliably as single-agent workflows.
2. You've written clear, unambiguous SKILL.md trigger descriptions (see [05 — Skills & Automation](../05-skills-and-automation.md)).
3. You've identified a *specific* coordination failure — not just "this feels complex."

## The simplest version

A two-tier structure is usually enough:
- **Tier 1:** A router that reads the input and calls the right skill.
- **Tier 2:** The skills themselves, unchanged.

The router's job is narrow: classify the input, pick the skill, hand off. It should not do the work itself.

(A fuller multi-agent setup guide is planned for a later version of this tool.)
