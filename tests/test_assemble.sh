#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"

PY="$(command -v python3 || command -v python || true)"
ASM="$ROOT/assemble.py"

assert_file_exists "$ASM" "assemble ships"
assert_file_exists "$ROOT/modules/README.md" "schema contract ships"
assert_file_exists "$ROOT/modules/inbox.md" "inbox module doc ships"
for m in daily projects research archive people; do
  assert_file_exists "$ROOT/modules/$m.md" "$m module doc ships"
done
daily_doc="$(cat "$ROOT/modules/daily.md")"
assert_contains "$daily_doc" "depends_on: [inbox]" "daily depends on inbox"
people_doc="$(cat "$ROOT/modules/people.md")"
assert_contains "$people_doc" "default: false" "people is opt-in"
assert_contains "$people_doc" "people/People.md — " "people ships a seed file"
readme="$(cat "$ROOT/modules/README.md")"
assert_contains "$readme" "depends_on" "contract documents depends_on"
assert_contains "$readme" "## Files" "contract documents the optional payload section"

if [ -z "$PY" ]; then
  pass "skipped assemble behavior (no python on PATH)"
else
  TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
  ROOT_PY="$ROOT"
  TMP_PY="$TMP"
  if command -v cygpath >/dev/null 2>&1; then
    ROOT_PY="$(cygpath -m "$ROOT")" || ROOT_PY="$ROOT"
    TMP_PY="$(cygpath -m "$TMP")" || TMP_PY="$TMP"
  fi

  # shipped modules/ validates clean
  vout="$("$PY" "$ASM" --validate)"; vrc=$?
  assert_eq "$vrc" "0" "shipped modules validate clean"
  assert_contains "$vout" "modules OK" "validate prints modules OK"
  assert_contains "$vout" "inbox" "validate names the module ids"
  assert_contains "$vout" "6 module(s)" "all six core docs validate"

  # a broken doc produces named problems and exit 1
  mkdir -p "$TMP/badmods"
  cat > "$TMP/badmods/wrong-id.md" <<'EOF'
---
id: mismatch
tier: shiny
title: Broken
---

## Concept
x
EOF
  printf 'no frontmatter here\n' > "$TMP/badmods/zz-nofm.md"
  bout="$("$PY" "$ASM" --validate --modules "$TMP/badmods" 2>&1)"; brc=$?
  assert_eq "$brc" "1" "broken module exits 1"
  assert_contains "$bout" "id 'mismatch' does not match filename" "validator flags id/filename mismatch"
  assert_contains "$bout" "tier must be one of" "validator flags bad tier"
  assert_contains "$bout" "missing section: Questions" "validator flags missing required sections"
  assert_contains "$bout" "zz-nofm.md" "parse failures aggregate across files"
  assert_contains "$bout" "no frontmatter block" "parse failure is a named problem line"

  # parser unit checks: questions, creates, files
  punit="$("$PY" -c "
import sys; sys.path.insert(0,'$ROOT_PY'); import assemble as a
qs=a.parse_questions('- sort_cadence — How often will you sort? (default: weekly)\n- plain_key — No default here')
print(qs[0]['key'], '|', qs[0]['default']); print(qs[1]['key'], '|', qs[1]['default'])
cr=a.parse_creates('- inbox/\n- people/People.md — index of people notes')
print(cr['folders']); print(cr['seeds'][0]['path'], '|', cr['seeds'][0]['desc'])
fl=a.parse_files('- \`scripts/jobs/jobslib.py\`\n- \`vault-template/applications/Applications.md\` → \`applications/Applications.md\`')
print(fl[0]['src'], '|', fl[0]['dest']); print(fl[1]['dest'])")"
  assert_contains "$punit" "sort_cadence | weekly" "question parser reads key + default"
  assert_contains "$punit" "plain_key | None" "question without default parses"
  assert_contains "$punit" "['inbox/']" "creates parser splits folders"
  assert_contains "$punit" "people/People.md | index of people notes" "creates parser splits seeds"
  assert_contains "$punit" "scripts/jobs/jobslib.py | scripts/jobs/jobslib.py" "files parser defaults dest to src"
  assert_contains "$punit" "applications/Applications.md" "files parser reads explicit dest"
fi
finish
