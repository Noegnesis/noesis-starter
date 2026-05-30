#!/usr/bin/env bash
# Dependency-free test helpers. Portable across macOS bash 3.2 and Git Bash.
TESTS_RUN=0; TESTS_FAILED=0
pass() { TESTS_RUN=$((TESTS_RUN+1)); echo "  ok   - $1"; }
fail() { TESTS_RUN=$((TESTS_RUN+1)); TESTS_FAILED=$((TESTS_FAILED+1)); echo "  FAIL - $1"; }
assert_contains()     { case "$1" in *"$2"*) pass "$3";; *) fail "$3 (missing: $2)";; esac; }
assert_not_contains() { case "$1" in *"$2"*) fail "$3 (found: $2)";; *) pass "$3";; esac; }
assert_eq() { if [ "$1" = "$2" ]; then pass "$3"; else fail "$3 (got '$1' want '$2')"; fi; }
assert_file_exists() { if [ -f "$1" ]; then pass "$2"; else fail "$2 (no file: $1)"; fi; }
finish() { echo "---"; echo "$TESTS_RUN run, $TESTS_FAILED failed"; [ "$TESTS_FAILED" -eq 0 ]; }
