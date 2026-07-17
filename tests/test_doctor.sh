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
body="$(cat "$ROOT/lib/doctor.sh")"
assert_contains "$body" "obsidian.json" "doctor reports where the vault registry lives"
# Parity guard, same shape as the installers'. This class of gap has already
# shipped once on this branch: setup.ps1 silently lacked a check setup.sh had,
# while the plan claimed parity. The two doctors drift for the same reason --
# nothing compares them. So compare them.
ps_body="$(cat "$ROOT/lib/doctor.ps1")"
assert_contains "$ps_body" "obsidian.json" "doctor.ps1 reports the registry too (parity with doctor.sh)"
# Anchor to the ARRAY LITERAL, not the bare token 'py'. The explanatory comment
# above the code also contains "'py'", so the old assertion passed even with the
# array reverted -- a reviewer reproduced exactly that. assert_contains is a
# whole-file substring match; give it something only the real code satisfies.
assert_contains "$ps_body" "@('python3', 'python', 'py')" "doctor.ps1 resolves the py launcher, like setup.ps1 does"
finish
