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

# Power branch drives the real module engine (Phase 2)
assert_contains "$body" "assemble.py" "power branch runs the assembler"
assert_contains "$body" ".noesis/answers.yaml" "power branch writes a vault-local answers file"
assert_contains "$body" "modules/" "power branch reads the module docs"
assert_contains "$body" "--execute" "power branch gates the write behind --execute"
assert_contains "$body" "finish this vault, then run" "power branch routes job-seekers to /jobs-setup"
assert_contains "$body" "managed region" "power branch defers folder/context rules to the assembler's region"

# Cross-platform rule, ALL skills: a skill that shells out to macOS `open`
# must also offer a Windows/Linux alternative (explorer / xdg-open).
for f in "$ROOT"/skills/*/SKILL.md; do
  name="$(basename "$(dirname "$f")")"
  skill_body="$(cat "$f")"
  case "$skill_body" in
    *'open "'*|*'open -a'*)
      case "$skill_body" in
        *explorer*|*xdg-open*) pass "$name: open command has a cross-platform alternative";;
        *) fail "$name: macOS-only open with no Windows/Linux alternative";;
      esac;;
    *) pass "$name: no macOS-only open usage";;
  esac
done
finish
