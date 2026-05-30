#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
count="$(ls "$ROOT/docs"/*.md 2>/dev/null | wc -l | tr -d ' ')"
if [ "$count" -ge 1 ]; then pass "prose docs folded into docs/"; else fail "docs/ has no prose guide yet"; fi
for f in typed-memory mcp-wiring agent-system adhd-patterns; do
  assert_file_exists "$ROOT/docs/advanced/$f.md" "advanced stub $f present"
done
finish
