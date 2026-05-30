#!/usr/bin/env bash
# Run every tests/test_*.sh; exit nonzero if any fails.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
rc=0
for t in "$HERE"/test_*.sh; do
  echo "== $(basename "$t") =="
  bash "$t" || rc=1
done
exit "$rc"
