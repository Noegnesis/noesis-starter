#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
count="$(ls "$ROOT/docs"/*.md 2>/dev/null | wc -l | tr -d ' ')"
if [ "$count" -ge 1 ]; then pass "prose docs folded into docs/"; else fail "docs/ has no prose guide yet"; fi
for f in typed-memory mcp-wiring agent-system adhd-patterns; do
  assert_file_exists "$ROOT/docs/advanced/$f.md" "advanced stub $f present"
done
# --- guide front door -------------------------------------------------------
assert_file_exists "$ROOT/docs/README.md" "guide front door docs/README.md exists"
front="$(cat "$ROOT/docs/README.md" 2>/dev/null || true)"
assert_contains "$front" "Weekend Minimalist" "front door has the Weekend Minimalist path"
assert_contains "$front" "ADHD-First Builder" "front door has the ADHD-First path"
assert_contains "$front" "The Researcher" "front door has the Researcher path"
assert_contains "$front" "The Power User" "front door has the Power User path"
assert_contains "$front" "advanced/typed-memory.md" "front door indexes the advanced docs"
assert_contains "$front" "augmenting-an-existing-vault.md" "front door indexes the augment guide"
assert_contains "$front" "second-brain-onboarding" "front door carries provenance line"
finish
