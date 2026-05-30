#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"; . "$ROOT/lib/vault_safety.sh"
V="$(mktemp -d)"; printf "old config\n" > "$V/CLAUDE.md"; printf "my note\n" > "$V/note.md"
backup_claude_md "$V"
baks="$(ls "$V"/CLAUDE.md.bak.* 2>/dev/null | wc -l | tr -d ' ')"
assert_eq "$baks" "1" "backs up an existing CLAUDE.md"
assert_eq "$(cat "$V/note.md")" "my note" "existing note left untouched"
V2="$(mktemp -d)"; backup_claude_md "$V2"
assert_eq "$(ls "$V2"/CLAUDE.md.bak.* 2>/dev/null | wc -l | tr -d ' ')" "0" "no backup when no CLAUDE.md exists"
finish
