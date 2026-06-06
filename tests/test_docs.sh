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
# --- every relative .md link in docs/ resolves -------------------------------
broken=""
for f in "$ROOT/docs"/*.md "$ROOT/docs/advanced"/*.md "$ROOT/docs/handoff"/*.md; do
  [ -f "$f" ] || continue
  dir="$(dirname "$f")"
  for link in $(grep -oE '\]\([^)#]+\.md' "$f" | sed 's/^](//'); do
    case "$link" in http*) continue;; esac
    [ -f "$dir/$link" ] || broken="$broken $(basename "$f")->$link"
  done
done
if [ -z "$broken" ]; then pass "all relative doc links resolve"; else fail "broken doc links:$broken"; fi

# --- alert markers outside code fences must be GitHub-valid types ------------
violations="$(awk '
  /^[[:space:]]*(```|~~~)/ { fence = !fence; next }
  !fence && /^> \[!/ && $0 !~ /^> \[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/ { print FILENAME }
' "$ROOT/docs"/*.md "$ROOT/docs/advanced"/*.md)"
if [ -z "$violations" ]; then pass "alert markers are GitHub-valid types"; else fail "invalid alert markers in: $violations"; fi

# --- restoration baseline: out-of-fence alert counts per core doc ------------
# (>= so future additions don't break; < means the fork dropped callouts again)
check_alert_floor() {
  n="$(awk '
    /^[[:space:]]*(```|~~~)/ { fence = !fence; next }
    !fence && /^> \[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/ { c++ }
    END { print c+0 }
  ' "$ROOT/docs/$1")"
  if [ "$n" -ge "$2" ]; then pass "docs/$1 has >= $2 alerts ($n)"; else fail "docs/$1 alert count $n < baseline $2"; fi
}
check_alert_floor 01-foundations-and-philosophy.md 3
check_alert_floor 02-obsidian-vault-setup.md 3
check_alert_floor 03-the-agent-layer-claude-code.md 4
check_alert_floor 04-connectors-and-tools.md 3
check_alert_floor 05-skills-and-automation.md 3
check_alert_floor 06-adhd-empowerment-system.md 4
check_alert_floor 07-sync-devices-and-maintenance.md 3
check_alert_floor 08-going-further-advanced.md 3

finish
