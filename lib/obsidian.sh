#!/usr/bin/env bash
# Open a folder as an Obsidian vault, cross-platform, with a guaranteed manual fallback.
open_vault_in_obsidian() {
  vault_path="$1"
  case "$(uname -s)" in
    Darwin) open -a Obsidian "$vault_path" >/dev/null 2>&1 || true ;;
    Linux)  xdg-open "obsidian://open?path=$vault_path" >/dev/null 2>&1 || true ;;
    *)      : ;;  # Windows Git Bash / unknown: rely on the printed manual step
  esac
  echo "If Obsidian did not open automatically:"
  echo "  Obsidian -> Open folder as vault -> $vault_path"
}
