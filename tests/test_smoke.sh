#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
assert_file_exists "$ROOT/setup.sh" "setup.sh present"
assert_file_exists "$ROOT/README.md" "README present"

body="$(cat "$ROOT/setup.sh")"
assert_contains "$body" "obsidian_list_vaults" "setup.sh discovers existing vaults from the registry"
assert_contains "$body" "Create a new vault" "setup.sh offers creating a new vault as a menu choice"
assert_contains "$body" "open_vault_in_obsidian" "setup.sh registers and opens the vault"
assert_contains "$body" "scripts/obsidian_vault.py" "setup.sh ships obsidian_vault.py into the vault"

assert_not_contains "$body" "second brain is ready" "setup.sh never declares success before the interview"
assert_contains "$body" "NOESIS_NO_HANDOFF" "setup.sh's handoff is suppressible for tests"
assert_contains "$body" 'exec claude --model opus' "setup.sh execs into the interview on opus"
assert_contains "$body" "not personalized yet" "setup.sh says what is actually true at handoff"

# The suppression gate is only real if it comes BEFORE the exec. A mere
# assert_contains proves the string exists somewhere -- a regression that moved
# the gate below `exec claude` would be dead code on every machine with claude
# on PATH, and every assertion above would still pass. Check the order.
nh_line="$(grep -n 'NOESIS_NO_HANDOFF' "$ROOT/setup.sh" | head -1 | cut -d: -f1)"
ex_line="$(grep -n 'exec claude' "$ROOT/setup.sh" | head -1 | cut -d: -f1)"
if [ -n "$nh_line" ] && [ -n "$ex_line" ] && [ "$nh_line" -lt "$ex_line" ]; then
  pass "the NOESIS_NO_HANDOFF gate precedes the exec"
else
  fail "the NOESIS_NO_HANDOFF gate precedes the exec (gate line '$nh_line', exec line '$ex_line')"
fi

ps="$(cat "$ROOT/setup.ps1")"
assert_contains "$ps" "obsidian_vault.py" "setup.ps1 uses the shared registry module"
assert_not_contains "$ps" 'Start-Process "obsidian://"' "setup.ps1 no longer blind-launches Obsidian"
assert_not_contains "$ps" "second brain is ready" "setup.ps1 never declares success before the interview"
assert_contains "$ps" "NOESIS_NO_HANDOFF" "setup.ps1's handoff is suppressible for tests"
assert_contains "$ps" "not personalized yet" "setup.ps1 says what is actually true at handoff"

# Parity guard. This exact gap shipped once: setup.sh got the running-Obsidian
# check and setup.ps1 silently didn't, while the plan claimed parity. The two
# installers drift precisely because nothing compares them -- so compare them.
assert_eq "$(grep -c 'check-running' "$ROOT/setup.sh")" "1" "setup.sh guards against a running Obsidian"
assert_eq "$(grep -c 'check-running' "$ROOT/setup.ps1")" "1" "setup.ps1 guards against a running Obsidian"

assert_contains "$ps" "\$env:Path = \$env:Path + ';'" "setup.ps1 EXTENDS PATH rather than replacing it (replacing drops process-only entries)"

finish
