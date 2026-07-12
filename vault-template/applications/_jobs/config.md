# Jobs config

> Your personal job-search config. Edit the YAML block below (or run `/jobs-setup`
> to fill it by interview). Secrets (e.g. Adzuna key) go in `.env`, never here.

```yaml
profile:
  name: "<your name>"
  contact: "<email>"
  location: "<city / remote>"
  work_auth: "<citizen / visa / etc.>"
  grad_status: "<student, grad date, or N/A>"

# 1-3 target tracks. Each lane's key is what you pass to /jobs and scaffold.py.
# keywords (optional) drive /jobs discover: a role matches a lane when its title
# or description hits one. Keep them high-precision - broad words drown you in noise.
lanes:
  - key: track-1
    label: "<your first target track>"
    description: "<what this track is and what it rewards>"
    anchor_keys: [anchor-1]
    keywords: []
  - key: track-2
    label: "<your second target track (optional)>"
    description: "<...>"
    anchor_keys: [anchor-1]
    keywords: []

# Your real evidence. Each anchor maps into résumé fragments + the Facts Ledger.
anchors:
  - key: anchor-1
    title: "<project / role>"
    one_line: "<what you did, honestly>"
    metrics: "<numbers if any>"
    lane_keys: [track-1]

voice_rules: "<your writing-voice constraints, e.g. terse; no em dashes>"

facts_ledger: "applications/Facts Ledger.md"

fragments:
  track-1: "applications/_fragments/Resume - track-1 (paste-ready).md"

discovery:
  ats_boards: []          # e.g. ["greenhouse:acme", "lever:acme", "ashby:acme"]
  feeds: []               # e.g. ["remotive:<search term>", "remoteok"]
  adzuna:
    app_id_ref: ADZUNA_APP_ID   # names of keys in .env
    app_key_ref: ADZUNA_APP_KEY
    country: us
    what: "<keywords>"
    where: "<location>"
  exclude_titles: []      # title phrases to always drop, e.g. ["staff accountant"]

paths:
  vault_root: null        # null = standalone; else absolute path to your vault
  applications_dir: null  # null = derive (vault_root/applications, or this folder)

tracker: bases            # "bases" (Obsidian) or "markdown"
```
