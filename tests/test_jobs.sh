#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"

PY="$(command -v python3 || command -v python || true)"

assert_file_exists "$ROOT/scripts/jobs/jobslib.py" "jobslib ships"

if [ -z "$PY" ]; then
  pass "skipped jobslib behavior (no python on PATH)"
else
  TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
  mkdir -p "$TMP/applications/_jobs"
  cat > "$TMP/applications/_jobs/config.md" <<'EOF'
# Jobs config
```yaml
profile:
  name: Test User
lanes:
  - key: track-1
    label: First Track
paths:
  vault_root: null
```
EOF
  cfg="$TMP/applications/_jobs/config.md"
  # Convert paths for Windows Python (use cygpath -m for mixed path format)
  JOBS_PATH="$ROOT/scripts/jobs"
  if command -v cygpath >/dev/null 2>&1; then
    JOBS_PATH="$(cygpath -m "$JOBS_PATH")" || JOBS_PATH="$ROOT/scripts/jobs"
    cfg="$(cygpath -m "$cfg")" || cfg="$TMP/applications/_jobs/config.md"
  fi
  # valid config: name + lane_keys + standalone applications_dir
  out="$("$PY" -c "import sys; sys.path.insert(0,'$JOBS_PATH'); import jobslib as j; c=j.load_config('$cfg'); print(c['profile']['name']); print(','.join(j.lane_keys(c))); print(j.validate_config(c)); print(j.resolve_paths(c,'$cfg')['applications_dir'])")"
  assert_contains "$out" "Test User" "load_config reads profile.name"
  assert_contains "$out" "track-1" "lane_keys returns the lane key"
  assert_contains "$out" "[]" "valid config yields no problems"
  assert_contains "$out" "applications" "standalone applications_dir resolves to the applications folder"

  # invalid config: no lanes
  cat > "$TMP/bad.md" <<'EOF'
```yaml
profile: {}
lanes: []
```
EOF
  bad_cfg="$TMP/bad.md"
  if command -v cygpath >/dev/null 2>&1; then
    bad_cfg="$(cygpath -m "$bad_cfg")" || bad_cfg="$TMP/bad.md"
  fi
  bad="$("$PY" -c "import sys; sys.path.insert(0,'$JOBS_PATH'); import jobslib as j; print(j.validate_config(j.load_config('$bad_cfg')))")"
  assert_contains "$bad" "profile.name is required" "validate flags missing name"
  assert_contains "$bad" "at least one lane is required" "validate flags missing lanes"

  # --- scaffold.py (config-driven) ---
  SC="$ROOT/scripts/jobs/scaffold.py"
  assert_file_exists "$SC" "scaffold ships"
  # dry-run: prints preview, writes nothing
  dry="$("$PY" "$SC" --config "$cfg" --org "Acme Co" --role "Widget Engineer" --lane track-1)"
  assert_contains "$dry" "dry-run" "scaffold dry-runs by default"
  assert_eq "$([ -d "$TMP/applications/Acme Co Widget Engineer" ] && echo yes || echo no)" "no" "dry-run writes nothing"
  # execute: writes the kit hub
  "$PY" "$SC" --config "$cfg" --org "Acme Co" --role "Widget Engineer" --lane track-1 --execute >/dev/null
  assert_file_exists "$TMP/applications/Acme Co Widget Engineer/Acme Co Widget Engineer.md" "execute writes the hub"
  # invalid lane is rejected against config lanes
  badlane="$("$PY" "$SC" --config "$cfg" --org "X" --role "Y" --lane not-a-lane 2>&1 || true)"
  assert_contains "$badlane" "not-a-lane" "unknown lane is rejected"
fi
finish
