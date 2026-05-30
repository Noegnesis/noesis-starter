#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
assert_file_exists "$ROOT/vault-template/daily/2026-01-01.md" "sample daily note exists"
assert_file_exists "$ROOT/vault-template/projects/example-project.md" "sample project note exists"
assert_contains "$(cat "$ROOT/vault-template/daily/2026-01-01.md")" "Top 3" "daily sample models the top-3 convention"
finish
