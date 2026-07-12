#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
assert_file_exists "$ROOT/vault-template/daily/2026-01-01.md" "sample daily note exists"
assert_file_exists "$ROOT/vault-template/projects/example-project.md" "sample project note exists"
assert_contains "$(cat "$ROOT/vault-template/daily/2026-01-01.md")" "Top 3" "daily sample models the top-3 convention"
assert_contains "$(cat "$ROOT/vault-template/daily/2026-01-01.md")" "Linked Today" "daily sample models the same-day hub"
assert_contains "$(cat "$ROOT/skills/daily/SKILL.md")" "Linked Today" "daily skill reconciles the same-day hub"
assert_contains "$(cat "$ROOT/CLAUDE.md")" "Linked Today" "CLAUDE.md carries the link-at-creation rule"
moc="$ROOT/vault-template/guide/MOC - Guide.md"
assert_file_exists "$moc" "vault-side guide MOC exists"
mocbody="$(cat "$moc" 2>/dev/null || true)"
assert_contains "$mocbody" "Weekend Minimalist" "MOC has the persona paths"
assert_contains "$mocbody" "(01-foundations-and-philosophy.md)" "MOC links docs by relative md links"
finish
