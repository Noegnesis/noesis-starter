#!/usr/bin/env bash
# Back up an existing CLAUDE.md before overwrite. Never touches notes or .obsidian/.
backup_claude_md() {
  vault_path="$1"
  target="$vault_path/CLAUDE.md"
  if [ -f "$target" ]; then
    ts="$(date +%Y%m%d-%H%M%S)"
    cp "$target" "$vault_path/CLAUDE.md.bak.$ts"
    echo "Backed up existing CLAUDE.md -> CLAUDE.md.bak.$ts"
  fi
}
