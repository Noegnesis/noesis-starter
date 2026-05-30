#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"; . "$ROOT/lib/doctor.sh"
BIN="$(mktemp -d)"
for t in git python3 claude brew uname; do printf '#!/bin/sh\nexit 0\n' > "$BIN/$t"; chmod +x "$BIN/$t"; done
# Ensure uname returns MINGW (not Darwin) so brew and Obsidian checks don't interfere
printf '#!/bin/sh\nprintf "MINGW64_NT"\n' > "$BIN/uname"
OLDPATH="$PATH"; export PATH="$BIN"
out="$(run_doctor)"; rc=$?
assert_eq "$rc" "0" "all required tools present -> 0 missing"
assert_contains "$out" "OK   git" "reports git ok"
/bin/rm -f "$BIN/claude"
out2="$(run_doctor)"; rc2=$?
assert_eq "$rc2" "1" "one missing tool -> rc 1"
assert_contains "$out2" "FAIL claude" "names the missing tool"
export PATH="$OLDPATH"
finish
