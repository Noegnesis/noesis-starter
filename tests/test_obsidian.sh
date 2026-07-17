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

  # --registry overrides resolution.
  # Do NOT assert exact string equality against "$TMP/custom.json": under Git
  # Bash, MSYS rewrites a POSIX path argument to a native Windows one before it
  # reaches a non-MSYS python, so the echoed path legitimately differs in FORM
  # from what bash passed. Assert the override's EFFECT instead -- custom.json
  # replaces the default obsidian.json entirely -- which is the actual behavior
  # under test and is identical on every platform.
  out="$("$PY" "$OV" --registry-path --registry "$TMP/custom.json" 2>&1)"
  assert_contains "$out" "custom.json" "--registry override reaches the resolver"
  assert_not_contains "$out" "obsidian.json" "--registry override replaces the default entirely"

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

  # --- register: fresh registry on a machine where Obsidian never launched ---
  mkdir -p "$TMP/fresh-vault"
  reg="$TMP/fresh/obsidian.json"
  id="$("$PY" "$OV" --register "$TMP/fresh-vault" --registry "$reg" 2>&1)"; rc=$?
  assert_eq "$rc" "0" "register creates a registry that did not exist"
  assert_file_exists "$reg" "register creates obsidian.json and its parent dir"
  case "$id" in
    [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]) pass "register prints a 16-char lowercase hex id";;
    *) fail "register prints a 16-char lowercase hex id (got '$id')";;
  esac
  out="$("$PY" "$OV" --list --registry "$reg" 2>&1)"
  assert_contains "$out" "fresh-vault" "the registered vault is now listed"

  # --- register is idempotent: same path re-registers under the SAME id ---
  id2="$("$PY" "$OV" --register "$TMP/fresh-vault" --registry "$reg" 2>&1)"
  assert_eq "$id2" "$id" "re-registering the same path reuses its id"
  lines="$("$PY" "$OV" --list --registry "$reg" 2>&1 | grep -c .)"
  assert_eq "$lines" "1" "re-registering does not duplicate the entry"

  # --- register preserves unknown top-level keys and unknown per-vault fields ---
  cp "$FIX/registry-two-vaults.json" "$TMP/existing.json"
  mkdir -p "$TMP/gamma"
  "$PY" "$OV" --register "$TMP/gamma" --registry "$TMP/existing.json" >/dev/null 2>&1
  body="$(cat "$TMP/existing.json")"
  assert_contains "$body" '"cli"' "unknown top-level key 'cli' survives a write"
  assert_contains "$body" '"color"' "unknown per-vault field 'color' survives a write"
  assert_contains "$body" "noesis-fixture-alpha" "pre-existing vaults survive a write"
  lines="$("$PY" "$OV" --list --registry "$TMP/existing.json" 2>&1 | grep -c .)"
  assert_eq "$lines" "3" "register adds to, rather than replaces, the vault list"

  # --- register backs up before writing ---
  bcount="$(ls "$TMP"/existing.json.backup-* 2>/dev/null | grep -c .)"
  assert_eq "$bcount" "1" "register backs the registry up before writing"

  # --- a second backup within the same second must not clobber the first ---
  # The pristine pre-Noesis vault list is the copy worth keeping; a
  # second-granularity filename alone would let the second write's backup
  # (already modified) silently replace it.
  cp "$FIX/registry-two-vaults.json" "$TMP/multi.json"
  mkdir -p "$TMP/d1" "$TMP/d2"
  "$PY" "$OV" --register "$TMP/d1" --registry "$TMP/multi.json" >/dev/null 2>&1
  "$PY" "$OV" --register "$TMP/d2" --registry "$TMP/multi.json" >/dev/null 2>&1
  bcount="$(ls "$TMP"/multi.json.backup-* 2>/dev/null | grep -c .)"
  assert_eq "$bcount" "2" "a same-second second backup does not clobber the first"
  oldest="$(ls "$TMP"/multi.json.backup-* | head -1)"
  assert_not_contains "$(cat "$oldest")" "d1" "the oldest backup still holds the pristine registry"

  # --- exactly one vault carries open:true, and it is ours ---
  opencount="$(grep -c '"open": true' "$TMP/existing.json")"
  assert_eq "$opencount" "1" "exactly one vault is marked open"

  # --- register REFUSES a malformed registry rather than clobbering it ---
  cp "$FIX/registry-malformed.json" "$TMP/bad.json"
  before="$(cat "$TMP/bad.json")"
  out="$("$PY" "$OV" --register "$TMP/gamma" --registry "$TMP/bad.json" 2>&1)"; rc=$?
  assert_eq "$rc" "1" "register on a malformed registry exits 1"
  assert_contains "$out" "not valid JSON" "register on a malformed registry explains why"
  assert_eq "$(cat "$TMP/bad.json")" "$before" "register leaves a malformed registry byte-identical"
  bcount="$(ls "$TMP"/bad.json.backup-* 2>/dev/null | grep -c .)"
  assert_eq "$bcount" "1" "register backs up even a malformed registry before refusing"

  # --- register rejects a path that is not a directory ---
  out="$("$PY" "$OV" --register "$TMP/does-not-exist" --registry "$reg" 2>&1)"; rc=$?
  assert_eq "$rc" "1" "register rejects a non-directory path"

  # --- open: registers, then reports the launch it would make ---
  # Do NOT assert the full string "Open folder as vault -> $TMP/openable": under
  # Git Bash, MSYS rewrites a POSIX path argument to a native Windows one before
  # it reaches a non-MSYS python (drive/separator syntax changes, filename
  # component does not -- same hazard as the --registry override note above).
  # Assert the fallback marker and the untouched filename component instead.
  mkdir -p "$TMP/openable"
  out="$("$PY" "$OV" --open "$TMP/openable" --registry "$TMP/open.json" --dry-run 2>&1)"; rc=$?
  assert_eq "$rc" "0" "--open --dry-run exits 0"
  assert_contains "$out" "would launch:" "--dry-run reports the launch instead of running it"
  assert_contains "$out" "Open folder as vault ->" "--open prints the manual fallback marker"
  assert_contains "$out" "openable" "--open's fallback names the target vault"
  out="$("$PY" "$OV" --list --registry "$TMP/open.json" 2>&1)"
  assert_contains "$out" "openable" "--open registers the vault before launching"

  # --- open prints the path AS PASSED, never normalized (Windows would differ) ---
  # Same MSYS boundary as above -- the leaf filename component ("my vault", with
  # its space) survives the rewrite, so check for that rather than the full
  # "/tmp/..." prefix. (The bottom-of-file assertion covers the same "raw path,
  # never normalized" design contract for lib/obsidian.sh's pre-existing bash
  # helper, which has no python/MSYS argv boundary to cross.)
  out="$("$PY" "$OV" --open "/tmp/my vault" --registry "$TMP/open.json" --dry-run 2>&1)"
  assert_contains "$out" "Open folder as vault ->" "--open echoes the fallback marker"
  assert_contains "$out" "my vault" "--open echoes the raw filename component, unmangled"

  # --- a failed registration still tells the user what to do by hand ---
  out="$("$PY" "$OV" --open "$TMP/nonexistent-dir" --registry "$TMP/open.json" --dry-run 2>&1)"; rc=$?
  assert_eq "$rc" "1" "--open on a bad path exits 1"
  assert_contains "$out" "Open folder as vault" "--open still prints the fallback when registration fails"

  # --- check-running answers without throwing ---
  "$PY" "$OV" --check-running >/dev/null 2>&1; rc=$?
  case "$rc" in
    0|1) pass "--check-running exits 0 or 1";;
    *)   fail "--check-running exits 0 or 1 (got $rc)";;
  esac
fi

out="$(open_vault_in_obsidian "/tmp/my vault" 2>&1)"
assert_contains "$out" "Open folder as vault -> /tmp/my vault" "always prints manual fallback with the path"
finish
