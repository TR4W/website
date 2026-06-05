#!/usr/bin/env bash
#
# release.sh — point the TR4W website at a new major release.
#
# Usage:   bin/release.sh <version> <date> [--skip-validation]
# Example: bin/release.sh 4.149.1 "July 2026"
#
# What it does (edits the working tree only — it does NOT commit or deploy):
#   1. Validates all 8 installers for the new version are already live on the
#      server (curl-checks they return 200). Refuses otherwise, so you never
#      publish dead download buttons.
#   2. Rewrites the single version in public_html/.htaccess (the redirect target).
#   3. Updates the visible version + date labels in public_html/index.html.
#   4. Prints the diff and stops. You review, commit, and push/merge to main;
#      the GitHub Actions deploy workflow (.github/workflows/deploy.yml) then
#      rsyncs the changed files to the server. GitHub is the single source of
#      truth — never rsync from your laptop. (Installers are uploaded separately.)
#
# Prereq: the new installers must already be uploaded to the server under
#         /<major>/ (e.g. /4.149/) before you run this.
#
set -euo pipefail

LANGS=(ukr rom ser ger rus cze mng esp)
BASE_URL="https://tr4w.net"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HT="$ROOT/public_html/.htaccess"
IDX="$ROOT/public_html/index.html"

die() { echo "ERROR: $*" >&2; exit 1; }

# ── args ────────────────────────────────────────────────────────────
NEW_VER="${1:-}"
NEW_DATE="${2:-}"
SKIP_VALIDATION=0
[ "${3:-}" = "--skip-validation" ] && SKIP_VALIDATION=1

if [ -z "$NEW_VER" ] || [ -z "$NEW_DATE" ]; then
  die 'usage: bin/release.sh <version> <date> [--skip-validation]
         e.g. bin/release.sh 4.149.1 "July 2026"'
fi
echo "$NEW_VER" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' \
  || die "version must look like 4.149.1 (major.minor.patch), got: $NEW_VER"

NEW_MAJOR="${NEW_VER%.*}"     # 4.149.1 -> 4.149

[ -f "$HT" ]  || die "not found: $HT"
[ -f "$IDX" ] || die "not found: $IDX"

# ── detect the CURRENT version + date from the live files ───────────
CUR_VER="$(grep -oE 'tr4w_setup_[0-9]+\.[0-9]+\.[0-9]+' "$HT" | head -1 | sed 's/tr4w_setup_//')"
[ -n "$CUR_VER" ] || die "could not detect current version in $HT"
CUR_MAJOR="${CUR_VER%.*}"
CUR_DATE="$(grep -oE '(January|February|March|April|May|June|July|August|September|October|November|December) [0-9]{4}' "$IDX" | head -1)"
[ -n "$CUR_DATE" ] || die "could not detect current date in $IDX"

echo "Current : $CUR_VER  ($CUR_DATE)   [dir: $CUR_MAJOR]"
echo "New     : $NEW_VER  ($NEW_DATE)   [dir: $NEW_MAJOR]"
echo

if [ "$CUR_VER" = "$NEW_VER" ] && [ "$CUR_DATE" = "$NEW_DATE" ]; then
  echo "Nothing to do — already at $NEW_VER ($NEW_DATE)."
  exit 0
fi

# ── validate the 8 installers are live on the server ────────────────
if [ "$SKIP_VALIDATION" -eq 1 ]; then
  echo "Skipping installer validation (--skip-validation)."
else
  echo "Validating installers under $BASE_URL/$NEW_MAJOR/ ..."
  files=("tr4w_setup_${NEW_VER}.exe")
  for l in "${LANGS[@]}"; do files+=("tr4w_setup_${NEW_VER}_${l}.exe"); done
  missing=()
  for f in "${files[@]}"; do
    code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 25 "$BASE_URL/$NEW_MAJOR/$f" || echo 000)"
    printf '  %-32s %s\n' "$f" "$code"
    [ "$code" = "200" ] || missing+=("$f")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    echo
    echo "REFUSING: ${#missing[@]} installer(s) not reachable (need HTTP 200) under $BASE_URL/$NEW_MAJOR/:"
    printf '  - %s\n' "${missing[@]}"
    echo "Upload the build artifacts to the server first, then re-run."
    exit 1
  fi
  echo "All ${#files[@]} installers present."
fi
echo

# ── apply edits (portable in-place via perl; \Q..\E escapes metachars) ──
replace() { # file old new
  OLD="$2" NEW="$3" perl -i -pe 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "$1"
}

# .htaccess: only the redirect target version
replace "$HT"  "/$CUR_MAJOR/tr4w_setup_$CUR_VER"  "/$NEW_MAJOR/tr4w_setup_$NEW_VER"
# index.html: display version (covers vX.Y.Z and bare X.Y.Z) + date
replace "$IDX" "$CUR_VER"  "$NEW_VER"
replace "$IDX" "$CUR_DATE" "$NEW_DATE"

# ── report ──────────────────────────────────────────────────────────
echo "=== diff (review before committing) ==="
git -C "$ROOT" --no-pager diff -- public_html/.htaccess public_html/index.html || true
echo
echo "Done (working tree only). Next steps:"
echo "  1. Review the diff above."
echo "  2. Commit and get it onto main (PR from a branch, or push straight to main):"
echo "       git add -A && git commit -m \"Release $NEW_VER ($NEW_DATE)\" && git push"
echo "  3. Merging to main triggers the deploy workflow, which rsyncs the changed"
echo "     files to the server automatically. GitHub is the source of truth — do"
echo "     NOT rsync from your laptop. Watch the run in the Actions tab."
echo "  4. Verify:  curl -sI https://tr4w.net/download/tr4w_setup.exe   (expect 302 -> /$NEW_MAJOR/...)"
