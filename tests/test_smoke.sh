#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"
assert_file_exists "$ROOT/setup.sh" "setup.sh present"
assert_file_exists "$ROOT/README.md" "README present"
finish
