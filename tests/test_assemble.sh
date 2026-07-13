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
  assert_contains "$vout" "8 module(s)" "all eight shipped docs validate"

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
  cat > "$TMP/badmods/badbody.md" <<'EOF'
---
id: badbody
tier: persona
title: Bad Body
default: maybe
---

## Concept
x

## Applies when
x

## Questions
- this is not a valid question bullet

## Creates
- x/

## CLAUDE.md snippet
```
- unterminated fence, no closing ticks
EOF
  cp "$TMP/badmods/wrong-id.md" "$TMP/badmods/dup-a.md"
  cp "$TMP/badmods/wrong-id.md" "$TMP/badmods/dup-b.md"
  bout="$("$PY" "$ASM" --validate --modules "$TMP/badmods" 2>&1)"; brc=$?
  assert_eq "$brc" "1" "broken module exits 1"
  assert_contains "$bout" "id 'mismatch' does not match filename" "validator flags id/filename mismatch"
  assert_contains "$bout" "tier must be one of" "validator flags bad tier"
  assert_contains "$bout" "missing section: Questions" "validator flags missing required sections"
  assert_contains "$bout" "zz-nofm.md" "parse failures aggregate across files"
  assert_contains "$bout" "no frontmatter block" "parse failure is a named problem line"
  assert_contains "$bout" "default must be true or false" "validator flags non-bool default"
  assert_contains "$bout" "unparseable question bullet" "validator flags a malformed question bullet"
  assert_contains "$bout" "unterminated fenced block" "validator flags an unterminated fence"
  assert_contains "$bout" "duplicate module id: mismatch" "validator flags duplicate ids across files"

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

  # --- fence-aware section split: '## ' inside a fenced block is NOT a heading ---
  fsec="$("$PY" -c "
import sys; sys.path.insert(0,'$ROOT_PY'); import assemble as a
body='''## Creates
- t/tmpl.md — a template
\`\`\`
# Title
## Prompt
what happened?
\`\`\`

## CLAUDE.md snippet
\`\`\`
- x
\`\`\`
'''
secs=a._split_sections(body)
print('KEYS', sorted(secs.keys()))
print('CREATES_HAS_PROMPT', '## Prompt' in secs['Creates'])")"
  assert_contains "$fsec" "KEYS ['CLAUDE.md snippet', 'Creates']" "fenced '## ' lines do not create sections"
  assert_contains "$fsec" "CREATES_HAS_PROMPT True" "fenced '## ' stays inside its section body"

  # --- resolution: deterministic topo order, cycle + unknown errors ---
  res="$("$PY" -c "
import sys; sys.path.insert(0,'$ROOT_PY'); import assemble as a
mods=a.load_modules('$ROOT_PY/modules')
print(a.resolve(['daily','archive'],mods))
try:
    a.resolve(['nope'],mods)
except a.ModuleError as e:
    print('ERR', e)")"
  assert_contains "$res" "['archive', 'inbox', 'daily']" "resolve pulls deps and sorts deterministically"
  assert_contains "$res" "ERR" "unknown module id raises"
  assert_contains "$res" "nope" "error names the unknown id"

  cyc="$("$PY" -c "
import sys; sys.path.insert(0,'$ROOT_PY'); import assemble as a
mods={'a':{'fm':{'id':'a','depends_on':['b']}},'b':{'fm':{'id':'b','depends_on':['a']}}}
try:
    a.resolve(['a'],mods)
except a.ModuleError as e:
    print('CYCLE', e)")"
  assert_contains "$cyc" "CYCLE" "dependency cycles raise"

  # --- rendering: answer > default > named missing ---
  ren="$("$PY" -c "
import sys; sys.path.insert(0,'$ROOT_PY'); import assemble as a
qs=[{'key':'x','prompt':'','default':'dflt'}]
print(a.render('v={{x}}','m',{'m':{'x':'ans'}},qs))
print(a.render('v={{x}}','m',{},qs))
print(a.render('v={{y}}','m',{},qs))")"
  assert_contains "$ren" "('v=ans', [])" "answers win"
  assert_contains "$ren" "('v=dflt', [])" "defaults fill"
  assert_contains "$ren" "'m.y'" "missing keys are named module.key"

  # --- dry-run: full plan printed, nothing written ---
  mkdir -p "$TMP/vault1"
  cat > "$TMP/answers.yaml" <<'EOF'
inbox:
  sort_cadence: daily
daily:
  daily_focus: top 3 priorities
EOF
  dryout="$("$PY" "$ASM" --select daily --answers "$TMP/answers.yaml" --dest "$TMP/vault1")"; drc=$?
  assert_eq "$drc" "0" "dry-run exits 0"
  assert_contains "$dryout" "inbox/" "plan lists dependency folders"
  assert_contains "$dryout" "daily/" "plan lists selected folders"
  assert_contains "$dryout" "cadence: daily" "plan renders answers into the region preview"
  assert_contains "$dryout" "dry-run" "plan says it wrote nothing"
  assert_eq "$(ls "$TMP/vault1" | wc -l | tr -d ' ')" "0" "dry-run writes nothing"

  # missing required answer is a named error
  miss="$("$PY" "$ASM" --select people --answers "$TMP/answers.yaml" --dest "$TMP/vault1" 2>&1)"; mrc=$?
  assert_eq "$mrc" "0" "people renders via default (exit 0)"
  assert_contains "$miss" "contact info and last conversation" "question defaults render in the plan"

  # --- execute: builds folders + seeds + region; never overwrites; idempotent ---
  V2="$TMP/vault2"; mkdir -p "$V2"
  printf '# My Vault\n\nuser content stays.\n' > "$V2/CLAUDE.md"
  "$PY" "$ASM" --select daily,people --answers "$TMP/answers.yaml" --dest "$V2" --execute >/dev/null
  assert_eq "$([ -d "$V2/inbox" ] && [ -d "$V2/daily" ] && [ -d "$V2/people" ] && echo yes)" "yes" "execute creates dependency + selected folders"
  assert_file_exists "$V2/people/People.md" "execute writes the seed file"
  seedtxt="$(cat "$V2/people/People.md")"
  assert_contains "$seedtxt" "contact info and last conversation" "seed content renders defaults"
  cl1="$(cat "$V2/CLAUDE.md")"
  assert_contains "$cl1" "user content stays." "user CLAUDE.md content preserved"
  assert_contains "$cl1" "noesis:modules:start" "managed region appended"
  assert_contains "$cl1" "cadence: daily" "region renders the answers"
  assert_eq "$(ls "$V2" | grep -c 'CLAUDE.md.bak')" "1" "existing CLAUDE.md backed up"

  # never-overwrite: user edits a seed; re-run must not clobber it, must not
  # add a backup (no-op region), and must report the region unchanged
  printf 'MINE\n' > "$V2/people/People.md"
  baks_before="$(ls "$V2" | grep -c 'CLAUDE.md.bak')"
  rerun="$("$PY" "$ASM" --select daily,people --answers "$TMP/answers.yaml" --dest "$V2" --execute)"
  assert_contains "$rerun" "skip (exists)" "re-run reports skipped seeds"
  assert_contains "$rerun" "region: unchanged" "no-op re-run reports the region unchanged"
  assert_eq "$(cat "$V2/people/People.md")" "MINE" "re-run never overwrites user files"
  baks_after="$(ls "$V2" | grep -c 'CLAUDE.md.bak')"
  assert_eq "$baks_after" "$baks_before" "no-op re-run adds no backup"
  cl2="$(sed -n '/noesis:modules:start/,/noesis:modules:end/p' "$V2/CLAUDE.md")"
  cl1r="$(printf '%s' "$cl1" | sed -n '/noesis:modules:start/,/noesis:modules:end/p')"
  assert_eq "$cl2" "$cl1r" "re-run leaves the managed region byte-identical"

  # region replacement: narrower selection replaces region + reports orphans
  orph="$("$PY" "$ASM" --select daily --answers "$TMP/answers.yaml" --dest "$V2" --execute)"
  assert_contains "$orph" "orphaned: People" "dropped modules reported as orphaned"
  cl3="$(cat "$V2/CLAUDE.md")"
  assert_not_contains "$(printf '%s' "$cl3" | sed -n '/noesis:modules:start/,/noesis:modules:end/p')" "### People" "dropped module leaves the region"
  assert_eq "$([ -d "$V2/people" ] && echo yes)" "yes" "orphaned folders are left in place"

  # payload copies: fixture module with a Files section, incl. dest mapping
  mkdir -p "$TMP/paymods"
  cp "$ROOT/modules/inbox.md" "$TMP/paymods/inbox.md"
  cat > "$TMP/paymods/payload.md" <<'EOF'
---
id: payload
tier: persona
title: Payload Fixture
depends_on: []
suggests: []
default: false
---

## Concept
x

## Applies when
x

## Questions

## Creates
- payloaddir/

## CLAUDE.md snippet
```
- payload module installed.
```

## Files
- `requirements.txt` → `payloaddir/requirements.txt`
EOF
  V3="$TMP/vault3"; mkdir -p "$V3"
  "$PY" "$ASM" --modules "$TMP/paymods" --select payload --answers "$TMP/answers.yaml" --dest "$V3" --execute >/dev/null
  assert_file_exists "$V3/payloaddir/requirements.txt" "payload copies land at the mapped dest"

  # --- hardening: traversal + malformed markers are refused ---
  cat > "$TMP/paymods/evil.md" <<'EOF'
---
id: evil
tier: persona
title: Evil Fixture
depends_on: []
suggests: []
default: false
---

## Concept
x

## Applies when
x

## Questions

## Creates
- ../escape.md — tries to climb out

## CLAUDE.md snippet
```
- x
```
EOF
  V4="$TMP/vault4"; mkdir -p "$V4"
  ev="$("$PY" "$ASM" --modules "$TMP/paymods" --select evil --answers "$TMP/answers.yaml" --dest "$V4" --execute 2>&1)"; evrc=$?
  assert_eq "$evrc" "1" "traversal paths are refused"
  assert_contains "$ev" "escapes the vault" "traversal error is named"
  assert_eq "$([ -f "$TMP/escape.md" ] && echo yes || echo no)" "no" "nothing written outside the vault"
  V5="$TMP/vault5"; mkdir -p "$V5"
  printf '%s\nuser\n%s\nmore\n' '<!-- noesis:modules:end -->' '<!-- noesis:modules:start -->' > "$V5/CLAUDE.md"
  mm="$("$PY" "$ASM" --select archive --answers "$TMP/answers.yaml" --dest "$V5" --execute 2>&1)"; mmrc=$?
  assert_eq "$mmrc" "1" "malformed markers are refused"
  assert_contains "$mm" "malformed" "marker error is named"

  # --- golden: full core selection matches the committed fixtures ---
  G="$TMP/golden"; mkdir -p "$G"
  "$PY" "$ASM" --select archive,inbox,daily,people,projects,research \
     --answers "$ROOT/tests/fixtures/engine/persona-core.answers.yaml" \
     --dest "$G" --execute >/dev/null
  tree_actual="$("$PY" -c "
from pathlib import Path
root=Path('$TMP_PY/golden')
entries=[]
for p in sorted(root.rglob('*')):
    rel=p.relative_to(root).as_posix()
    if rel.startswith('CLAUDE.md.bak'): continue
    entries.append(rel+'/' if p.is_dir() else rel)
print('\n'.join(sorted(entries)))" | tr -d '\r')"
  assert_eq "$tree_actual" "$(tr -d '\r' < "$ROOT/tests/fixtures/engine/golden-tree.txt")" "golden tree matches"
  region_actual="$(sed -n '/noesis:modules:start/,/noesis:modules:end/p' "$G/CLAUDE.md" | tr -d '\r')"
  assert_eq "$region_actual" "$(tr -d '\r' < "$ROOT/tests/fixtures/engine/golden-claude-region.md")" "golden CLAUDE.md region matches"

  # --- persona golden: journaler (journal/reflection layer, fenced seed) ---
  PJ="$TMP/pj"; mkdir -p "$PJ"
  "$PY" "$ASM" --select daily,journal-reflection \
     --answers "$ROOT/tests/fixtures/engine/persona-journaler.answers.yaml" \
     --dest "$PJ" --execute >/dev/null
  pj_tree="$("$PY" -c "
from pathlib import Path
root=Path('$TMP_PY/pj'); out=[]
for p in sorted(root.rglob('*')):
    rel=p.relative_to(root).as_posix()
    if rel.startswith('CLAUDE.md.bak'): continue
    out.append(rel+'/' if p.is_dir() else rel)
print('\n'.join(sorted(out)))" | tr -d '\r')"
  assert_eq "$pj_tree" "$(tr -d '\r' < "$ROOT/tests/fixtures/engine/persona-journaler.tree.txt")" "journaler golden tree matches"
  pj_region="$(sed -n '/noesis:modules:start/,/noesis:modules:end/p' "$PJ/CLAUDE.md" | tr -d '\r')"
  assert_eq "$pj_region" "$(tr -d '\r' < "$ROOT/tests/fixtures/engine/persona-journaler.claude-region.md")" "journaler golden region matches"
  pj_seed="$(cat "$PJ/reflections/Reflection Template.md")"
  assert_contains "$pj_seed" "## What happened" "fenced '## ' headings survive into the rendered seed"
  assert_contains "$pj_seed" "write this weekly" "seed placeholders render from answers"

  # --- persona golden: researcher (persona module depends_on a core module) ---
  PR="$TMP/pr"; mkdir -p "$PR"
  "$PY" "$ASM" --select research-augment \
     --answers "$ROOT/tests/fixtures/engine/persona-researcher.answers.yaml" \
     --dest "$PR" --execute >/dev/null
  pr_tree="$("$PY" -c "
from pathlib import Path
root=Path('$TMP_PY/pr'); out=[]
for p in sorted(root.rglob('*')):
    rel=p.relative_to(root).as_posix()
    if rel.startswith('CLAUDE.md.bak'): continue
    out.append(rel+'/' if p.is_dir() else rel)
print('\n'.join(sorted(out)))" | tr -d '\r')"
  assert_eq "$pr_tree" "$(tr -d '\r' < "$ROOT/tests/fixtures/engine/persona-researcher.tree.txt")" "researcher golden tree matches"
  pr_region="$(sed -n '/noesis:modules:start/,/noesis:modules:end/p' "$PR/CLAUDE.md" | tr -d '\r')"
  assert_eq "$pr_region" "$(tr -d '\r' < "$ROOT/tests/fixtures/engine/persona-researcher.claude-region.md")" "researcher golden region matches"
  assert_contains "$pr_region" "### Research & Notes" "depends_on pulls the core research module into the region"
fi
finish
