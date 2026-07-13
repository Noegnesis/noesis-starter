---
id: jobs
tier: advanced
title: Job Search
depends_on: []
suggests: []
default: false
---

## Concept
The job-search pipeline as the engine's first payload module: discover roles, score fit across your lanes, tailor an application kit in your voice, and track everything in applications/. This doc is the module's machine-validated file boundary — its `## Files` payload is checked by `assemble.py --validate` (every source must exist and stay within the repo).

## Applies when
The user is job-searching. The Power interview does NOT offer this module — job-seekers are routed to `/jobs-setup`, which stands up the pipeline interactively. This doc exists to declare and validate the jobs payload.

## Questions

## Creates
- applications/

## CLAUDE.md snippet
```
- Job-search kits, the Facts Ledger, and the Applications tracker live in applications/. Run /jobs to ingest a role, score fit, and tailor a kit; run /jobs-setup to onboard the pipeline.
```

## Slash commands
- jobs — ingest a posting, score fit, tailor a kit, track it (`skills/jobs/SKILL.md`)
- jobs-setup — onboarding interview: config, resume fragments, Facts Ledger (`skills/jobs-setup/SKILL.md`)

## Files
- `scripts/jobs/jobslib.py`
- `scripts/jobs/scaffold.py`
- `scripts/jobs/discover.py`
- `scripts/jobs/annotate.py`
- `scripts/jobs/templates/kit-hub.md`
- `scripts/jobs/templates/resume-fragment.md`
- `workflows/company-scan.js`
- `vault-template/applications/_jobs/config.md` → `applications/_jobs/config.md`
- `vault-template/applications/_jobs/.env.example` → `applications/_jobs/.env.example`
- `vault-template/applications/_jobs/.gitignore` → `applications/_jobs/.gitignore`
- `vault-template/applications/Facts Ledger.md` → `applications/Facts Ledger.md`
- `vault-template/applications/Cover Letter - Base.md` → `applications/Cover Letter - Base.md`
- `vault-template/applications/Applications.base` → `applications/Applications.base`
- `vault-template/applications/Applications.md` → `applications/Applications.md`
- `vault-template/applications/_sample-kit/Sample Co Sample Role/Sample Co Sample Role.md` → `applications/_sample-kit/Sample Co Sample Role/Sample Co Sample Role.md`
- `docs/advanced/job-search.md` → `guide/advanced/job-search.md`
