#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
hits=""
while IFS= read -r term; do
  case "$term" in ''|\#*) continue;; esac
  found="$(cd "$ROOT" && grep -R -I -l -i --exclude-dir=.git --exclude-dir=tests -- "$term" . 2>/dev/null || true)"
  [ -n "$found" ] && hits="$hits
$term -> $found"
done < "$HERE/personal-denylist.txt"
if [ -n "$hits" ]; then fail "personal data present:$hits"; else pass "no personal identifiers in shipped files"; fi
finish
