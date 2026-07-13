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
finish
