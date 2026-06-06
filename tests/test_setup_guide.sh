#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
sh_body="$(cat "$ROOT/setup.sh")"
ps_body="$(cat "$ROOT/setup.ps1")"
assert_contains "$sh_body" "Include the full guide in your vault?" "setup.sh prompts for the guide (default yes)"
assert_contains "$sh_body" '/guide/advanced' "setup.sh creates guide/advanced in the vault"
assert_contains "$sh_body" 'MOC - Guide.md' "setup.sh installs the MOC"
assert_not_contains "$sh_body" 'docs/handoff' "setup.sh never copies handoff docs into vaults"
assert_contains "$ps_body" "Include the full guide in your vault?" "setup.ps1 prompts for the guide (default yes)"
assert_contains "$ps_body" 'guide\advanced' "setup.ps1 creates guide\advanced in the vault"
assert_contains "$ps_body" 'MOC - Guide.md' "setup.ps1 installs the MOC"
assert_not_contains "$ps_body" 'docs\handoff' "setup.ps1 never copies handoff docs into vaults"
finish
