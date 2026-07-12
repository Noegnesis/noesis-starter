#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"

PY="$(command -v python3 || command -v python || true)"

assert_file_exists "$ROOT/scripts/jobs/discover.py" "discover ships"
tmpl="$(cat "$ROOT/vault-template/applications/_jobs/config.md")"
assert_contains "$tmpl" "keywords:" "config template documents lane keywords"
assert_contains "$tmpl" "exclude_titles:" "config template documents exclude_titles"
gi="$(cat "$ROOT/vault-template/applications/_jobs/.gitignore")"
assert_contains "$gi" "state/" "discovery state dir is gitignored"

if [ -z "$PY" ]; then
  pass "skipped discover behavior (no python on PATH)"
else
  TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
  mkdir -p "$TMP/applications/_jobs"
  cat > "$TMP/applications/_jobs/config.md" <<'EOF'
# Jobs config
```yaml
profile:
  name: Fixture Friend
lanes:
  - key: track-a
    label: Track A
    keywords: [widget research]
  - key: track-b
    label: Track B
    keywords: [gizmo engineering]
discovery:
  ats_boards: []
  feeds: []
  adzuna:
    app_id_ref: FIXTURE_UNSET_ID
    app_key_ref: FIXTURE_UNSET_KEY
  exclude_titles: [staff accountant]
paths:
  vault_root: null
```
EOF
  cfg="$TMP/applications/_jobs/config.md"
  JOBS_PATH="$ROOT/scripts/jobs"
  cfg_py="$cfg"
  if command -v cygpath >/dev/null 2>&1; then
    JOBS_PATH="$(cygpath -m "$JOBS_PATH")" || JOBS_PATH="$ROOT/scripts/jobs"
    cfg_py="$(cygpath -m "$cfg")" || cfg_py="$cfg"
  fi

  # parsers: greenhouse fixture -> role with stable key + excerpt
  gh="$("$PY" -c "
import sys; sys.path.insert(0,'$JOBS_PATH'); import discover as d
payload={'jobs':[{'id':7,'title':'Widget Researcher','absolute_url':'https://x/7',
 'location':{'name':'Remote'},'updated_at':'2026-01-01','content':'<p>study widgets</p>'}]}
r=d.parse_greenhouse(payload,'Acme Co','acme')[0]
print(r['stable_key']); print(r['role']); print(r['remote']); print(r['jd_excerpt'])")"
  assert_contains "$gh" "gh:acme:7" "greenhouse parser builds the stable key"
  assert_contains "$gh" "Widget Researcher" "greenhouse parser reads the title"
  assert_contains "$gh" "True" "greenhouse parser detects remote"
  assert_contains "$gh" "study widgets" "greenhouse parser strips html from excerpt"

  # board entry parsing + lane guessing + exclusion, driven by the config
  logic="$("$PY" -c "
import sys; sys.path.insert(0,'$JOBS_PATH'); import discover as d, jobslib as j
cfg=j.load_config('$cfg_py')
print(d.parse_board('greenhouse:acme'))
kw=d.lane_keyword_map(cfg)
print(d.guess_lane({'role':'Senior Widget Research Lead','jd_excerpt':''},kw))
print(d.guess_lane({'role':'Chef','jd_excerpt':''},kw))
print(d.is_excluded({'role':'Staff Accountant'},['staff accountant']))")"
  assert_contains "$logic" "('greenhouse', 'acme')" "board entries parse to (ats, slug)"
  assert_contains "$logic" "track-a" "lane keywords from config drive the lane guess"
  assert_contains "$logic" "False" "excluded-title check is case-insensitive"

  # dedupe: stable key already seen -> dropped
  dd="$("$PY" -c "
import sys; sys.path.insert(0,'$JOBS_PATH'); import discover as d
roles=[{'stable_key':'gh:acme:7','company':'Acme Co','role':'Widget Researcher'},
       {'stable_key':'gh:acme:8','company':'Acme Co','role':'Gizmo Engineer'}]
fresh,skipped=d.dedupe(roles,{'gh:acme:7'})
print(len(fresh),len(skipped)); print(fresh[0]['stable_key'])")"
  assert_contains "$dd" "1 1" "dedupe drops seen stable keys"
  assert_contains "$dd" "gh:acme:8" "dedupe keeps the fresh role"

  # end-to-end dry run, zero boards, zero network: exits 0, writes nothing
  dry="$("$PY" "$ROOT/scripts/jobs/discover.py" --config "$cfg" --source all 2>&1)"; rc=$?
  assert_eq "$rc" "0" "dry run with empty boards exits 0"
  assert_contains "$dry" "fetched=0" "dry run reports zero fetched"
  assert_contains "$dry" "dry-run" "dry run says nothing was written"
  assert_eq "$(ls "$TMP/applications" | grep -cv '^_jobs$')" "0" "dry run writes no kit folders"

  # write_stub goes through scaffold's template: discovered hub with jd placeholder
  st="$("$PY" -c "
import sys; sys.path.insert(0,'$JOBS_PATH'); import discover as d
from pathlib import Path
hub=d.write_stub({'company':'Acme Co','role':'Widget Researcher','url':'https://x/7',
 'stable_key':'gh:acme:7','location':'Remote','remote':True,'lane_guess':'track-a',
 'jd_excerpt':'study widgets','liveness':'verified'}, apps_dir=Path('$cfg_py').parent.parent)
print(hub); print(hub.read_text(encoding='utf-8'))")"
  assert_contains "$st" "status: discovered" "stub carries status discovered"
  assert_contains "$st" "gh:acme:7" "stub carries the stable key"
  assert_contains "$st" "attach one with --jd-file" "stub fills the jd_line placeholder"
  assert_contains "$st" "study widgets" "stub carries the jd excerpt"
fi
finish
