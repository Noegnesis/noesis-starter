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

finish
