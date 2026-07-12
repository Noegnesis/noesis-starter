#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"

PY="$(command -v python3 || command -v python || true)"
JOBSLIB="$ROOT/scripts/jobs/jobslib.py"

assert_file_exists "$ROOT/scripts/jobs/templates/resume-fragment.md" "resume fragment template ships"
frag="$(cat "$ROOT/scripts/jobs/templates/resume-fragment.md")"
assert_contains "$frag" "{lane}" "fragment template is tokenized by lane"
assert_contains "$frag" "{anchor_bullets}" "fragment template carries anchor slots"

assert_file_exists "$ROOT/skills/jobs-setup/SKILL.md" "jobs-setup skill ships"
ss="$(cat "$ROOT/skills/jobs-setup/SKILL.md")"
assert_contains "$ss" "jobslib.py validate" "skill validates the config it writes"
assert_contains "$ss" "_fragments" "skill seeds resume fragments"
assert_contains "$ss" "Facts Ledger" "skill seeds the facts ledger"
assert_contains "$ss" ".env" "skill routes secrets to .env"
assert_contains "$ss" "gitignored" "skill notes .env is gitignored"
assert_contains "$ss" "build it" "skill gates the build on confirmation"

if [ -z "$PY" ]; then
  pass "skipped jobs-setup behavior (no python on PATH)"
else
  TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
  mkdir -p "$TMP/applications/_jobs"
  cat > "$TMP/applications/_jobs/config.md" <<'EOF'
# Jobs config
```yaml
profile:
  name: Fixture Friend
lanes:
  - key: track-a
    label: Track A
paths:
  vault_root: null
```
EOF
  ok_out="$("$PY" "$JOBSLIB" validate "$TMP/applications/_jobs/config.md")"; ok_rc=$?
  assert_eq "$ok_rc" "0" "validate exits 0 on a valid config"
  assert_contains "$ok_out" "config OK" "validate prints config OK"
  assert_contains "$ok_out" "track-a" "validate names the lanes"

  cat > "$TMP/bad.md" <<'EOF'
```yaml
profile: {}
lanes: []
```
EOF
  bad_out="$("$PY" "$JOBSLIB" validate "$TMP/bad.md")"; bad_rc=$?
  assert_eq "$bad_rc" "1" "validate exits 1 on an invalid config"
  assert_contains "$bad_out" "problem:" "validate prints problem lines"

  miss_out="$("$PY" "$JOBSLIB" validate "$TMP/nope.md" 2>&1)"; miss_rc=$?
  assert_eq "$miss_rc" "1" "validate exits 1 when the config cannot load"
  assert_contains "$miss_out" "error:" "validate reports the load error"
fi
finish
