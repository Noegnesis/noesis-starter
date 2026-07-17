#!/usr/bin/env bash
# Thin wrapper over scripts/obsidian_vault.py, which owns Obsidian's vault
# registry. Everything real happens there; this exists so shell callers have a
# function, and so the manual fallback still prints when Python is missing.

# Resolve the module relative to this file, not the caller's cwd.
_obsidian_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOESIS_OBSIDIAN_PY="${NOESIS_OBSIDIAN_PY:-$_obsidian_lib_dir/../scripts/obsidian_vault.py}"

noesis_python() { command -v python3 2>/dev/null || command -v python 2>/dev/null || true; }

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

# obsidian_open_vault PATH -> register PATH, then launch Obsidian into it
open_vault_in_obsidian() {
  vault_path="$1"
  py="$(noesis_python)"
  if [ -n "$py" ] && [ -f "$NOESIS_OBSIDIAN_PY" ]; then
    # Must be an `if` condition, not `cmd && return 0`: setup.sh runs under
    # `set -e`, where a trailing failed &&-list would abort the installer.
    if "$py" "$NOESIS_OBSIDIAN_PY" --open "$vault_path"; then
      return 0
    fi
  fi
  # No Python, or registration failed: the manual step always works.
  echo "If Obsidian did not open automatically:"
  echo "  Obsidian -> Open folder as vault -> $vault_path"
  return 0
}
