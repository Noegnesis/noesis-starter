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
  # Advisory, never counted: absent just means Obsidian has not launched yet.
  # Use the probed resolver when it's loaded (setup.sh sources both libs) --
  # presence is not proof it runs. Fall back to a bare lookup when doctor.sh is
  # sourced on its own.
  if command -v noesis_python >/dev/null 2>&1; then
    py="$(noesis_python)"
  else
    py="$(command -v python3 2>/dev/null || command -v python 2>/dev/null || true)"
  fi
  ov="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/obsidian_vault.py"
  if [ -n "$py" ] && [ -f "$ov" ]; then
    reg="$("$py" "$ov" --registry-path 2>/dev/null || true)"
    if [ -n "$reg" ] && [ -f "$reg" ]; then
      echo "  OK   Obsidian vault registry ($reg)"
    else
      echo "  WARN No obsidian.json yet — setup will create it (normal before Obsidian's first launch)"
    fi
  fi
  return "$missing"
}
