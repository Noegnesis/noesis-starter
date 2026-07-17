#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"; . "$ROOT/lib/obsidian.sh"

PY="$(command -v python3 || command -v python || true)"
OV="$ROOT/scripts/obsidian_vault.py"
FIX="$HERE/fixtures/obsidian"

if [ -z "$PY" ]; then
  pass "skipped obsidian_vault behavior (no python on PATH)"
else
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT

  # --registry-path resolves to an obsidian.json under an obsidian dir
  out="$("$PY" "$OV" --registry-path 2>&1)"
  assert_contains "$out" "obsidian.json" "--registry-path names obsidian.json"
  assert_contains "$out" "obsidian" "--registry-path is under an obsidian dir"

  # --registry overrides resolution
  out="$("$PY" "$OV" --registry-path --registry "$TMP/custom.json" 2>&1)"
  assert_eq "$out" "$TMP/custom.json" "--registry overrides the resolved path"

  # --list on a populated registry prints one path per line
  out="$("$PY" "$OV" --list --registry "$FIX/registry-two-vaults.json" 2>&1)"
  assert_contains "$out" "/tmp/noesis-fixture-alpha" "--list prints the first vault"
  assert_contains "$out" "/tmp/noesis-fixture-beta" "--list prints the second vault"
  lines="$(printf '%s\n' "$out" | grep -c .)"
  assert_eq "$lines" "2" "--list prints exactly one line per vault"

  # --list on a MISSING registry is empty + exit 0 (fresh machine, Obsidian never launched)
  out="$("$PY" "$OV" --list --registry "$TMP/nope.json" 2>/dev/null)"; rc=$?
  assert_eq "$rc" "0" "--list on a missing registry exits 0"
  assert_eq "$out" "" "--list on a missing registry prints nothing"

  # --list on a MALFORMED registry fails loudly rather than pretending it is empty
  out="$("$PY" "$OV" --list --registry "$FIX/registry-malformed.json" 2>&1)"; rc=$?
  assert_eq "$rc" "1" "--list on a malformed registry exits 1"
  assert_contains "$out" "not valid JSON" "--list on a malformed registry explains why"
fi

out="$(open_vault_in_obsidian "/tmp/my vault" 2>&1)"
assert_contains "$out" "Open folder as vault -> /tmp/my vault" "always prints manual fallback with the path"
finish
