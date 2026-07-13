---
id: journal-reflection
tier: persona
title: Journal & Reflection
depends_on: []
suggests: [daily]
default: false
---

## Concept
A two-layer writing practice: raw daily journal entries you never edit, and sparse, curated reflections you write when a theme crystallizes. Keeps unfiltered voice separate from considered synthesis.

## Applies when
The user mentions journaling, reflection, processing emotions, or keeping a private writing practice.

## Questions
- reflection_cadence — How often do you expect to write a reflection? (default: when something crystallizes)

## Creates
- journal/
- reflections/
- reflections/Reflection Template.md — starter template for a reflection entry
```
# Reflection

## What happened
(the raw material — pull from recent journal/ entries)

## What it means
(the considered take — write this {{reflection_cadence}})

## What changes
(one concrete next action)
```

## CLAUDE.md snippet
```
- Raw journal entries live in journal/ — never edit them; they are your unfiltered voice.
- Curated reflections live in reflections/ (write one {{reflection_cadence}}); read a recent one before writing to match voice.
```

## Memory rules
- Never overwrite a raw journal entry with a cleaned-up version.
