#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"

# the engine ships in the repo
assert_file_exists "$ROOT/assemble.py" "assemble.py present in repo"
assert_file_exists "$ROOT/modules/README.md" "module schema contract present in repo"

# both installers ship the assembler + module docs into vaults
sh_body="$(cat "$ROOT/setup.sh")"
assert_contains "$sh_body" "assemble.py" "setup.sh ships the assembler"
assert_contains "$sh_body" "modules/" "setup.sh ships module docs"
ps_body="$(cat "$ROOT/setup.ps1")"
assert_contains "$ps_body" "assemble.py" "setup.ps1 ships the assembler"
assert_contains "$ps_body" "modules" "setup.ps1 ships module docs"
finish
