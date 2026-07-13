---
id: people
tier: core
title: People
depends_on: []
suggests: []
default: false
---

## Concept
One place for the people in your orbit — colleagues, collaborators, friends — so context about a person is never scattered.

## Applies when
The user mentions tracking relationships, clients, a team, or networking.

## Questions
- people_fields — What do you want tracked per person? (default: contact info and last conversation)

## Creates
- people/
- people/People.md — index of people notes
```
# People

> One entry per person: {{people_fields}}.
```

## CLAUDE.md snippet
```
- Person notes live in people/ ({{people_fields}}). When a new person comes up, offer to add them to people/People.md.
```
