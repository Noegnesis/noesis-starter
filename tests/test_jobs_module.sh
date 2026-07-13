#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib.sh"

assert_file_exists "$ROOT/workflows/company-scan.js" "company-scan workflow ships"
scan="$(cat "$ROOT/workflows/company-scan.js")"
assert_contains "$scan" "export const meta" "workflow carries a meta block"
assert_contains "$scan" "confirm" "workflow is opt-in gated"
assert_contains "$scan" "TOKENS_PER_COMPANY" "workflow computes a token estimate"
assert_contains "$scan" "DEFAULT_MAX_COMPANIES" "workflow caps the default company set"
assert_not_contains "$scan" "Date.now" "workflow avoids Date.now (breaks resume)"
finish
