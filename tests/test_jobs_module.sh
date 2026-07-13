#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"

assert_file_exists "$ROOT/workflows/company-scan.js" "company-scan workflow ships"
scan="$(cat "$ROOT/workflows/company-scan.js")"
assert_contains "$scan" "export const meta" "workflow carries a meta block"
assert_contains "$scan" "confirm" "workflow is opt-in gated"
assert_contains "$scan" "TOKENS_PER_COMPANY" "workflow computes a token estimate"
assert_contains "$scan" "DEFAULT_MAX_COMPANIES" "workflow caps the default company set"
assert_not_contains "$scan" "Date.now" "workflow avoids Date.now (breaks resume)"

js="$(cat "$ROOT/skills/jobs/SKILL.md")"
assert_contains "$js" "discover.py" "skill documents discover mode"
assert_contains "$js" "annotate.py" "skill documents score mode"
assert_contains "$js" "company-scan.js" "skill documents scan mode"
assert_contains "$js" "confirm: true" "skill surfaces the scan cost gate"
assert_contains "$js" "judge loop" "skill documents the judge loop"
assert_contains "$js" "Cover Letter Ledger" "judge loop feeds the ledger"
sh_body="$(cat "$ROOT/setup.sh")"
assert_contains "$sh_body" "discover.py" "setup.sh ships discover"
assert_contains "$sh_body" "annotate.py" "setup.sh ships annotate"
assert_contains "$sh_body" "company-scan.js" "setup.sh ships the scan workflow"
ps_body="$(cat "$ROOT/setup.ps1")"
assert_contains "$ps_body" "discover.py" "setup.ps1 ships discover"
assert_contains "$ps_body" "annotate.py" "setup.ps1 ships annotate"
assert_contains "$ps_body" "company-scan.js" "setup.ps1 ships the scan workflow"
guide="$(cat "$ROOT/docs/advanced/job-search.md" 2>/dev/null || true)"
assert_contains "$guide" "Facts Ledger" "guide teaches the facts-ledger discipline"
assert_contains "$guide" "judge loop" "guide teaches the judge loop"
assert_contains "$guide" "caps the tier at C" "guide carries the seniority hard-fail rule"
front="$(cat "$ROOT/docs/README.md")"
assert_contains "$front" "advanced/job-search.md" "front door indexes the job-search guide"
# Phase-2: the flat manifest is retired; modules/jobs.md is the validated declaration
# (assemble.py --validate machine-checks its ## Files payload — see test_assemble.sh's
# "10 module(s)" assertion, which only passes if every jobs source exists in the repo).
MOD="$ROOT/modules/jobs.md"
assert_file_exists "$MOD" "jobs module doc ships"
assert_eq "$([ -f "$ROOT/skills/jobs/module.manifest.md" ] && echo yes || echo no)" "no" "flat manifest retired"
md="$(cat "$MOD")"
for f in scripts/jobs/jobslib.py scripts/jobs/scaffold.py scripts/jobs/discover.py \
         scripts/jobs/annotate.py workflows/company-scan.js docs/advanced/job-search.md; do
  assert_contains "$md" "$f" "jobs module declares $f"
done
assert_contains "$md" "Applications.base" "jobs module declares the tracker payload"
assert_contains "$md" "jobs-setup" "jobs module defers onboarding to /jobs-setup"
finish
