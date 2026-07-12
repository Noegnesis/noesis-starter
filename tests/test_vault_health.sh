#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"

assert_file_exists "$ROOT/scripts/vault_health.py" "scanner ships"
assert_file_exists "$ROOT/skills/vault-health/SKILL.md" "skill ships"
skill="$(cat "$ROOT/skills/vault-health/SKILL.md")"
assert_contains "$skill" "fix-plan" "skill previews fixes before applying"
assert_contains "$skill" "undo" "skill writes an undo log"
assert_contains "$skill" "voice: raw" "skill documents the raw-voice guard"

# Behavioral check against a throwaway fixture vault (skipped if no python).
PY="$(command -v python3 || command -v python || true)"
if [ -z "$PY" ]; then
  pass "skipped scanner behavior (no python on PATH)"
else
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  mkdir -p "$TMP/projects" "$TMP/research" "$TMP/inbox" "$TMP/daily" "$TMP/guide"
  cat > "$TMP/projects/MOC - Projects.md" <<'EOF'
# MOC — Projects
- [[alpha]]
EOF
  cat > "$TMP/projects/alpha.md" <<'EOF'
Links to [[does-not-exist]] and back to [[MOC - Projects]].
EOF
  echo "no links here" > "$TMP/research/lonely.md"
  echo "# guide doc, must be skipped" > "$TMP/guide/ignored.md"
  echo "unsorted" > "$TMP/inbox/dropped.txt"
  echo "# 2026-01-01" > "$TMP/daily/2026-01-01.md"

  out="$("$PY" "$ROOT/scripts/vault_health.py" "$TMP")"
  assert_contains "$out" '"does-not-exist"' "detects the broken link"
  assert_contains "$out" 'research/lonely' "detects the active orphan"
  assert_not_contains "$out" 'ignored' "skips the generated guide/ folder"
  assert_contains "$out" '"count": 1' "counts the inbox backlog"
  case "$out" in
    *'daily/2026-01-01'*) fail "periodic daily note wrongly flagged as orphan";;
    *) pass "periodic daily note not flagged as orphan";;
  esac

  pulse="$("$PY" "$ROOT/scripts/vault_health.py" "$TMP" --pulse)"
  assert_contains "$pulse" 'broken link' "pulse emits the one-liner"
  assert_contains "$pulse" '/vault-health' "pulse nudges toward the full audit"
fi
finish
