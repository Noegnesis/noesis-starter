#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"; . "$ROOT/lib/obsidian.sh"
out="$(open_vault_in_obsidian "/tmp/my vault" 2>&1)"
assert_contains "$out" "Open folder as vault -> /tmp/my vault" "always prints manual fallback with the path"
finish
