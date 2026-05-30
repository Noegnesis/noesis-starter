#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
body="$(cat "$ROOT/skills/vault-setup/SKILL.md")"
assert_not_contains "$body" 'open -a Obsidian "$(pwd)"' "no bare macOS-only open command"
assert_contains "$body" "Open folder as vault" "documents the manual vault-open fallback"
assert_contains "$body" "Basic" "offers a basic branch"
assert_contains "$body" "Power" "offers a power branch"
assert_contains "$body" "more tokens" "power branch carries a token heads-up"
finish
