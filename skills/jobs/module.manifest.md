# noesis-jobs — module manifest

The declared boundary of the job-search module. When the Phase-2 modules/
architecture lands, modules/jobs/ is a mechanical move of exactly these files;
until then, nothing job-related may live outside this set. (Backticked paths in
this file are machine-checked against the repo — keep them real.)

## Skills
- `skills/jobs/SKILL.md`
- `skills/jobs-setup/SKILL.md`
- `skills/jobs/module.manifest.md` (this file)

## Scripts
- `scripts/jobs/jobslib.py`
- `scripts/jobs/scaffold.py`
- `scripts/jobs/discover.py`
- `scripts/jobs/annotate.py`
- `scripts/jobs/templates/kit-hub.md`
- `scripts/jobs/templates/resume-fragment.md`

## Workflows
- `workflows/company-scan.js`

## Vault scaffold
- `vault-template/applications/_jobs/config.md`
- `vault-template/applications/_jobs/.env.example`
- `vault-template/applications/_jobs/.gitignore`
- vault-template/applications/Facts Ledger.md
- vault-template/applications/Cover Letter - Base.md
- `vault-template/applications/Applications.base`
- `vault-template/applications/Applications.md`
- vault-template/applications/_sample-kit/Sample Co Sample Role/Sample Co Sample Role.md

## Docs
- `docs/advanced/job-search.md`

## Tests
- `tests/test_jobs.sh`
- `tests/test_jobs_setup.sh`
- `tests/test_jobs_discover.sh`
- `tests/test_jobs_module.sh`

## Dependencies
- Claude Code (skills, Workflow tool) — required
- Python 3.9+ with `pyyaml` — required (`python-dotenv` optional)
- Obsidian — optional (markdown tracker fallback without it)
- Adzuna API keys in the config folder's .env — optional (discovery runs ATS + feeds without them)

## Install surface (wired in setup.sh / setup.ps1)
- `skills/jobs`, `skills/jobs-setup` → vault + global skill installs
- `scripts/jobs/` + `workflows/company-scan.js` → vault copies
- `vault-template/applications/` → vault applications/ scaffold (never overwrites)
