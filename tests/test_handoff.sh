#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
f="$ROOT/docs/handoff/fresh-user-test.md"
assert_file_exists "$f" "handoff protocol exists"
body="$(cat "$f" 2>/dev/null || true)"
assert_contains "$body" "--check" "protocol uses the doctor pre-check"
assert_contains "$body" "token" "protocol captures token cost on a Pro budget"
finish
