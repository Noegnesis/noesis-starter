#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
mac_line="$(grep -n "setup.sh" "$ROOT/README.md" | head -1 | cut -d: -f1)"
win_line="$(grep -n "setup.ps1" "$ROOT/README.md" | head -1 | cut -d: -f1)"
if [ -n "$mac_line" ] && [ -n "$win_line" ] && [ "$mac_line" -lt "$win_line" ]; then
  pass "macOS install appears before Windows"
else
  fail "macOS one-liner must come before Windows (mac=$mac_line win=$win_line)"
fi
body="$(cat "$ROOT/README.md")"
assert_contains "$body" "Kashef" "credits Kashef / Prompt Advisers for installer prior-art"
assert_contains "$body" "beta" "macOS path is labeled beta until hardware-verified"
assert_contains "$body" "docs/README.md" "README routes readers to the guide front door"
# Anchor on copy this branch actually introduced. The old assertions passed
# against the pre-fix README unchanged -- /vault-setup already appeared in the
# skills table, and "Type /vault-setup" never appeared verbatim -- so reverting
# the whole rewrite kept the suite green.
assert_contains "$body" "the interview that makes the vault yours" "README describes the handoff in the new copy"
assert_contains "$body" "isn't on your PATH yet" "README is honest that the auto-launch can miss"
finish
