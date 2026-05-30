#!/usr/bin/env bash
# Report on prerequisites without installing anything. Returns count of missing required CLIs.
run_doctor() {
  missing=0
  tools="git python3 claude"
  [ "$(uname -s)" = "Darwin" ] && tools="brew $tools"
  for tool in $tools; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "  OK   $tool"
    else
      echo "  FAIL $tool not found"
      missing=$((missing+1))
    fi
  done
  # Obsidian is a GUI app, not a required CLI: advise only, never count.
  if [ "$(uname -s)" = "Darwin" ] && [ -d "/Applications/Obsidian.app" ]; then
    echo "  OK   Obsidian"
  else
    echo "  WARN Obsidian not detected (macOS: brew install --cask obsidian)"
  fi
  return "$missing"
}
