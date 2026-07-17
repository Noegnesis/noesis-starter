#!/usr/bin/env bash
# Thin wrapper over scripts/obsidian_vault.py, which owns Obsidian's vault
# registry. Everything real happens there; this exists so shell callers have a
# function, and so the manual fallback still prints when Python is missing.

# Resolve the module relative to this file, not the caller's cwd.
_obsidian_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOESIS_OBSIDIAN_PY="${NOESIS_OBSIDIAN_PY:-$_obsidian_lib_dir/../scripts/obsidian_vault.py}"

# Resolve a python that actually RUNS. Presence is not proof: Windows ships
# App Execution Alias stubs for python3/python that resolve on PATH, open the
# Microsoft Store, and exit 9009 -- and a broken interpreter resolves fine too.
# Callers treat empty output as "no python" and fall back to the manual path.
noesis_python() {
  for _c in python3 python; do
    _p="$(command -v "$_c" 2>/dev/null || true)"
    if [ -n "$_p" ] && "$_p" -c "pass" >/dev/null 2>&1; then
      echo "$_p"
      return 0
    fi
  done
  return 0
}

# obsidian_list_vaults [registry_override] -> one vault path per line
obsidian_list_vaults() {
  py="$(noesis_python)"
  [ -z "$py" ] && return 0
  if [ -n "${1:-}" ]; then
    "$py" "$NOESIS_OBSIDIAN_PY" --list --registry "$1" 2>/dev/null || true
  else
    "$py" "$NOESIS_OBSIDIAN_PY" --list 2>/dev/null || true
  fi
}

# open_vault_in_obsidian PATH -> register PATH, then launch Obsidian into it
open_vault_in_obsidian() {
  vault_path="$1"
  py="$(noesis_python)"
  if [ -n "$py" ] && [ -f "$NOESIS_OBSIDIAN_PY" ]; then
    # The module prints the fallback itself on BOTH success and failure, so once
    # we have delegated, our own copy would double it -- and on Git Bash the two
    # copies disagree, because MSYS rewrites the path the module receives.
    # `|| true` + an unconditional `return 0`: setup.sh sources this under
    # `set -e`, where a failing tail command would abort the whole installer.
    "$py" "$NOESIS_OBSIDIAN_PY" --open "$vault_path" || true
    return 0
  fi
  # Delegation was impossible (no Python, or the module is missing). This echo
  # is the no-Python floor -- the one copy of the string that cannot delegate.
  echo "If Obsidian did not open automatically:"
  echo "  Obsidian -> Open folder as vault -> $vault_path"
  return 0
}
