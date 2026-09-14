#!/usr/bin/env bash
#
# test-publish-release.sh — unit tests for the helpers in bin/publish-release.sh.
#
# Usage: bin/test-publish-release.sh
#
# Extracts the helper block (http_code … wait_until_live) from the real script
# and runs it against a stubbed http_code, so the Cloudflare cached-404 handling
# is exercised without touching the network or the server. Exits non-zero if
# any case fails.
#
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/bin/publish-release.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/tr4w-test.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

# Helper block: from the http_code() line through wait_until_live's closing brace.
awk '/^http_code\(\)/{on=1} on{print} on && /^}$/{exit}' "$SCRIPT" > "$WORK/helpers.sh"
grep -q '^wait_until_live()' "$WORK/helpers.sh" \
  || { echo "FAIL: could not extract wait_until_live from $SCRIPT"; exit 1; }

# The script's output helpers, minus colour; die exits like the real one.
ok()   { printf 'ok: %s\n' "$*"; }
warn() { printf 'warn: %s\n' "$*"; }
die()  { printf 'die: %s\n' "$*"; exit 1; }
DRY_RUN=0
# shellcheck source=/dev/null
source "$WORK/helpers.sh"
sleep() { :; }

# Stubbed http_code. It runs inside $(…), so the call counter lives in a file.
#   STALE_CALLS — how many edge requests return 404 before EDGE takes over
#   EDGE        — edge answer after that
#   ORIGIN      — answer for cache-busted (?nocache=) requests, i.e. the origin
http_code() {
  case "$1" in
    *nocache=*) echo "$ORIGIN" ;;
    *)
      local n; n="$(cat "$WORK/calls")"
      echo $((n + 1)) > "$WORK/calls"
      if [ "$n" -lt "$STALE_CALLS" ]; then echo 404; else echo "$EDGE"; fi ;;
  esac
}

FAILED=0
check() { # check <name> <want-exit> <want-substring>
  local out rc
  echo 0 > "$WORK/calls"
  out="$(wait_until_live https://tr4w.net/9.9/a.exe https://tr4w.net/9.9/b.exe 2>&1)"; rc=$?
  # An empty want-substring means "any output" (grep never matches empty input).
  if [ "$rc" -eq "$2" ] && { [ -z "$3" ] || printf '%s' "$out" | grep -qF -- "$3"; }; then
    printf 'PASS  %s\n' "$1"
  else
    printf 'FAIL  %s (exit %s, want %s; output lacks "%s")\n%s\n' "$1" "$rc" "$2" "$3" "$out"
    FAILED=1
  fi
}

EDGE_WAIT=300; STALE_CALLS=0;   EDGE=200; ORIGIN=200
check "all files live → returns"                      0 ""

EDGE_WAIT=300; STALE_CALLS=999; EDGE=404; ORIGIN=404
check "origin 404 → dies immediately, not waiting"    1 "not reachable on the server itself"

EDGE_WAIT=300; STALE_CALLS=2;   EDGE=200; ORIGIN=200
check "cached 404 that expires → waits, then returns" 0 "rechecking in 20s"

EDGE_WAIT=0;   STALE_CALLS=999; EDGE=404; ORIGIN=200
check "cached 404 that never expires → dies"          1 "Cloudflare still serves a cached 404"

DRY_RUN=1
if [ "$(did uploaded)" = "warn: dry run — would have: uploaded" ]; then
  echo "PASS  did() in a dry run reports the skipped action"
else
  echo "FAIL  did() in a dry run printed: $(did uploaded)"; FAILED=1
fi
DRY_RUN=0
if [ "$(did uploaded)" = "ok: uploaded" ]; then
  echo "PASS  did() in a real run reports success"
else
  echo "FAIL  did() in a real run printed: $(did uploaded)"; FAILED=1
fi

exit "$FAILED"
