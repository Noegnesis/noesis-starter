#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"

PY="$(command -v python3 || command -v python || true)"
JOBSLIB="$ROOT/scripts/jobs/jobslib.py"

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
