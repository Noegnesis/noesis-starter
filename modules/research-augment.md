---
id: research-augment
tier: persona
title: Literature & Citations
depends_on: [research]
suggests: []
default: false
---

## Concept
Adds a literature layer on top of research/: a place for source material and citation-ready notes, so a paper or literature review can be assembled from tracked sources.

## Applies when
The user mentions papers, citations, a literature review, or tracking sources.

## Questions
- citation_style — What citation style do you use? (default: whatever the venue wants)

## Creates
- research/sources/
- research/Literature Notes.md — one note per source, citation-ready
```
# Literature Notes

One entry per source. Citation style: {{citation_style}}.
```

## CLAUDE.md snippet
```
- Source material lives in research/sources/; citation-ready notes in research/Literature Notes.md ({{citation_style}}).
- When citing, pull the exact source note rather than paraphrasing from memory.
```
