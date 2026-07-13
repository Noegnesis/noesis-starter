---
id: asset-portfolio
tier: persona
title: Portfolio & Assets
depends_on: [projects]
suggests: []
default: false
---

## Concept
A showcase layer for finished work: a portfolio index plus an assets/ folder for the images, exports, and files that back each piece.

## Applies when
The user mentions a portfolio, showcasing work, managing creative assets, or a body of finished pieces.

## Questions
- asset_kinds — What kinds of assets do you keep? (default: images and exports)

## Creates
- portfolio/
- assets/
- portfolio/Portfolio.md — index of finished pieces
```
# Portfolio

One entry per finished piece, linking its assets ({{asset_kinds}}).
```

## CLAUDE.md snippet
```
- Finished pieces are indexed in portfolio/Portfolio.md; their {{asset_kinds}} live in assets/.
- Pull a project from projects/ into portfolio/ only once it is done.
```
