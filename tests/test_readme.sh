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
finish
