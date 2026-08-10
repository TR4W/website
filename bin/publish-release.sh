#!/usr/bin/env bash
#
# publish-release.sh — put a TR4W release on tr4w.net, end to end.
#
# Usage:   bin/publish-release.sh <VER> "<MONTH YEAR>" [options]
# Example: bin/publish-release.sh 4.150.0 "August 2026"
#
# This is the executable form of bin/RELEASE_RUNBOOK.md. It runs every step in
# order, verifies each one, and refuses to continue when a check fails:
#
#   1. Preflight     — tools, gh auth, clean git tree, on main
#   2. Fetch         — pull the 9 installers from the GitHub release
#   3. Verify DTA    — extract TRMASTER.DTA from the installer, compare against
#                      the copy committed to TR4W/TR4W (a *check*, not the source)
#   4. Upload        — rsync the 9 installers to the host, confirm all HTTP 200
#   5. Refresh DTA   — only if the DB actually changed; backs up the live copy first
#   6. Repoint       — bin/release.sh (htaccess redirect + index.html labels)
#   7. Ship          — commit, push to main, wait for the deploy workflow
#   8. Confirm       — all 9 /download/ URLs 302 to the new dir; labels updated
#
# Nothing irreversible happens without a y/N prompt (--yes to skip them, or
# --dry-run to rehearse the whole thing writing nothing).
#
# WHY THE DTA IS HANDLED THIS WAY
#   The standalone https://tr4w.net/TRMASTER.DTA must match the database inside
#   the installer users just downloaded. So the installer's copy is the source of
#   truth here; the repo copy at TR4W/TR4W:tr4w/target/TRMASTER.DTA is compared
#   against it and a mismatch is a hard stop. The old runbook trusted the repo
#   copy blind, with only a `wc -c` sanity check that catches an HTML error page
#   but not a genuinely stale-yet-valid database.
#
#   Whether to advance the "Callsign database · <MONTH>" label in index.html is
#   likewise decided by hashing, not by asking: if the new DTA is byte-identical
#   to what the site already serves, the DB did not change and the date is left
#   alone.
#
set -euo pipefail

LANGS=(ukr rom ser ger rus cze mng esp)
BASE_URL="https://tr4w.net"
APP_REPO="TR4W/TR4W"
SITE_REPO="TR4W/website"
SERVER="TR4W"
DOCROOT="/var/www/tr4w.net/public_html"
DTA_IN_APP_REPO="tr4w/target/TRMASTER.DTA"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IDX="$ROOT/public_html/index.html"
HT="$ROOT/public_html/.htaccess"

# ── output helpers ──────────────────────────────────────────────────
if [ -t 1 ]; then
  B=$'\033[1m'; R=$'\033[31m'; G=$'\033[32m'; Y=$'\033[33m'; Z=$'\033[0m'
else
  B=""; R=""; G=""; Y=""; Z=""
fi
step() { printf '\n%s══ %s %s\n' "$B" "$*" "$Z"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$Z" "$*"; }
warn() { printf '  %s!%s %s\n' "$Y" "$Z" "$*"; }
die()  { printf '\n%sERROR:%s %s\n' "$R" "$Z" "$*" >&2; exit 1; }

confirm() { # confirm "<prompt>"
  [ "$ASSUME_YES" -eq 1 ] && { ok "auto-confirmed: $1"; return 0; }
  local reply
  printf '\n%s%s%s [y/N] ' "$B" "$1" "$Z"
  read -r reply </dev/tty || true
  case "$reply" in [yY]|[yY][eE][sS]) return 0 ;; *) die "aborted by user." ;; esac
}

run() { # run a state-changing command, honouring --dry-run
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '  [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

http_code() { curl -sS -o /dev/null -w '%{http_code}' --max-time 30 "$1" 2>/dev/null || echo 000; }
sha256()    { shasum -a 256 "$1" | cut -d' ' -f1; }

# ── args ────────────────────────────────────────────────────────────
VER=""; MONTH=""; TAG=""
DRY_RUN=0; ASSUME_YES=0; SKIP_UPLOAD=0; NO_PUSH=0

usage() {
  printf '%s\n' \
    'Usage: bin/publish-release.sh <VER> "<MONTH YEAR>" [options]' \
    '' \
    '  <VER>            full version, e.g. 4.150.0' \
    '  "<MONTH YEAR>"   release month, e.g. "August 2026"' \
    '' \
    'Options:' \
    '  --tag <TAG>      GitHub release tag        (default: v<VER>-all)' \
    '  --dry-run        rehearse; write nothing, anywhere' \
    '  --yes            skip all confirmation prompts' \
    '  --skip-upload    installers are already on the host' \
    '  --no-push        stop after the local commit (do not push to main)' \
    '  -h, --help       this text'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --tag)         TAG="${2:-}"; shift 2 ;;
    --dry-run)     DRY_RUN=1; shift ;;
    --yes)         ASSUME_YES=1; shift ;;
    --skip-upload) SKIP_UPLOAD=1; shift ;;
    --no-push)     NO_PUSH=1; shift ;;
    -h|--help)     usage 0 ;;
    -*)            die "unknown option: $1" ;;
    *)
      if   [ -z "$VER" ];   then VER="$1"
      elif [ -z "$MONTH" ]; then MONTH="$1"
      else die "unexpected argument: $1"
      fi
      shift ;;
  esac
done

[ -n "$VER" ] && [ -n "$MONTH" ] || usage 1
echo "$VER" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' \
  || die "version must look like 4.150.0 (major.minor.patch), got: $VER"
echo "$MONTH" | grep -qE '^(January|February|March|April|May|June|July|August|September|October|November|December) [0-9]{4}$' \
  || die "date must look like \"August 2026\", got: $MONTH"

MAJOR="${VER%.*}"                       # 4.150.0 -> 4.150
[ -n "$TAG" ] || TAG="v${VER}-all"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/tr4w-release-$VER.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT

printf '%s\n' \
  "" \
  "${B}TR4W release publisher${Z}" \
  "  version : $VER   (dir /$MAJOR/)" \
  "  date    : $MONTH" \
  "  tag     : $TAG   ($APP_REPO)" \
  "  target  : $SERVER:$DOCROOT"
[ "$DRY_RUN" -eq 1 ] && warn "DRY RUN — nothing will be written locally or on the server."

# ── 1. preflight ────────────────────────────────────────────────────
step "1/8  Preflight"

SEVENZ=""
for c in 7z 7zz 7za; do command -v "$c" >/dev/null 2>&1 && { SEVENZ="$c"; break; }; done
[ -n "$SEVENZ" ] || die "need 7z to verify TRMASTER.DTA inside the installer (brew install sevenzip)."
for c in gh curl rsync ssh git shasum perl; do
  command -v "$c" >/dev/null 2>&1 || die "missing required tool: $c"
done
ok "tools present (archiver: $SEVENZ)"

gh auth status >/dev/null 2>&1 || die "gh is not authenticated — run: gh auth login"
ok "gh authenticated"

BRANCH="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)"
[ "$BRANCH" = "main" ] || die "on branch '$BRANCH'; releases are cut from main."
if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  git -C "$ROOT" status --short
  die "working tree is dirty. Commit or stash first — this script makes its own commit."
fi
ok "on main, working tree clean"

git -C "$ROOT" fetch --quiet origin main
if [ -n "$(git -C "$ROOT" rev-list HEAD..origin/main 2>/dev/null)" ]; then
  die "local main is behind origin/main. Pull first."
fi
ok "main is up to date with origin"

ssh -n -o BatchMode=yes -o ConnectTimeout=10 "$SERVER" true 2>/dev/null \
  || die "cannot ssh to '$SERVER' non-interactively. Check your ssh config/agent."
ok "ssh to $SERVER works"

CUR_VER="$(grep -oE 'tr4w_setup_[0-9]+\.[0-9]+\.[0-9]+' "$HT" | head -1 | sed 's/tr4w_setup_//')"
[ -n "$CUR_VER" ] || die "could not read the current version from $HT"
[ "$CUR_VER" != "$VER" ] || die "site already points at $VER — nothing to do."
ok "site currently advertises $CUR_VER"

# ── 2. fetch the release assets ─────────────────────────────────────
step "2/8  Fetch installers from $APP_REPO@$TAG"

gh release view "$TAG" --repo "$APP_REPO" >/dev/null 2>&1 \
  || die "release '$TAG' not found in $APP_REPO. Pass --tag if it is named differently."

mkdir -p "$STAGE/installers"
gh release download "$TAG" --repo "$APP_REPO" \
  --pattern "tr4w_setup_${VER}*.exe" --dir "$STAGE/installers" >/dev/null \
  || die "failed to download assets for $TAG."

EXPECTED=("tr4w_setup_${VER}.exe")
for l in "${LANGS[@]}"; do EXPECTED+=("tr4w_setup_${VER}_${l}.exe"); done
missing=()
for f in "${EXPECTED[@]}"; do
  [ -s "$STAGE/installers/$f" ] || missing+=("$f")
done
if [ "${#missing[@]}" -gt 0 ]; then
  printf '  missing from the release:\n'; printf '    - %s\n' "${missing[@]}"
  die "${#missing[@]} of ${#EXPECTED[@]} installers are absent from $TAG. Fix the build, then re-run."
fi
extra="$(find "$STAGE/installers" -name '*.exe' | wc -l | tr -d ' ')"
ok "all ${#EXPECTED[@]} installers downloaded ($extra .exe files staged)"

# ── 3. verify TRMASTER.DTA ──────────────────────────────────────────
step "3/8  Verify TRMASTER.DTA"

MAIN_EXE="$STAGE/installers/tr4w_setup_${VER}.exe"
mkdir -p "$STAGE/dta"
"$SEVENZ" e -y "$MAIN_EXE" -o"$STAGE/dta" 'TRMASTER.DTA' -r >/dev/null 2>&1 || true
SHIPPED="$STAGE/dta/TRMASTER.DTA"
[ -s "$SHIPPED" ] || die "could not extract TRMASTER.DTA from $(basename "$MAIN_EXE"). Installer format changed?"
SHIPPED_SHA="$(sha256 "$SHIPPED")"
ok "extracted from installer: $(wc -c < "$SHIPPED" | tr -d ' ') bytes  sha256 ${SHIPPED_SHA:0:16}…"

# cross-check against the copy the build machine committed to the app repo
if curl -fsL --max-time 60 -o "$STAGE/dta/repo.DTA" \
     "https://raw.githubusercontent.com/$APP_REPO/master/$DTA_IN_APP_REPO"; then
  REPO_SHA="$(sha256 "$STAGE/dta/repo.DTA")"
  if [ "$REPO_SHA" = "$SHIPPED_SHA" ]; then
    ok "matches $APP_REPO master — build machine committed the right database"
  else
    warn "MISMATCH with $APP_REPO master ($DTA_IN_APP_REPO)"
    warn "  installer : ${SHIPPED_SHA:0:16}…  $(wc -c < "$SHIPPED" | tr -d ' ') bytes"
    warn "  repo      : ${REPO_SHA:0:16}…  $(wc -c < "$STAGE/dta/repo.DTA" | tr -d ' ') bytes"
    warn "The installer's copy is what users get, so that is what will be published."
    warn "But the build machine did not commit this database — investigate after the release."
    confirm "Publish the installer's copy and continue anyway?"
  fi
else
  warn "could not fetch $DTA_IN_APP_REPO from $APP_REPO (cross-check skipped)"
fi

# decide whether the DB actually changed, by hashing what is live right now
DB_CHANGED=1
if curl -fsL --max-time 60 -o "$STAGE/dta/live.DTA" "$BASE_URL/TRMASTER.DTA"; then
  LIVE_SHA="$(sha256 "$STAGE/dta/live.DTA")"
  if [ "$LIVE_SHA" = "$SHIPPED_SHA" ]; then
    DB_CHANGED=0
    ok "live copy is already identical — callsign DB did NOT change this release"
    ok "  → the \"Callsign database · <MONTH>\" label will be left untouched"
  else
    ok "live copy differs (${LIVE_SHA:0:16}…) — DB changed, will refresh and re-date"
  fi
else
  warn "could not fetch the live $BASE_URL/TRMASTER.DTA — assuming the DB changed"
fi

# ── 4. upload installers ────────────────────────────────────────────
step "4/8  Publish installers to $SERVER:$DOCROOT/$MAJOR/"

if [ "$SKIP_UPLOAD" -eq 1 ]; then
  ok "--skip-upload given, not uploading"
else
  confirm "Upload ${#EXPECTED[@]} installers to $SERVER:$DOCROOT/$MAJOR/ ?"
  run ssh -n "$SERVER" "mkdir -p $DOCROOT/$MAJOR"
  run rsync -av "$STAGE/installers/" "$SERVER:$DOCROOT/$MAJOR/"
  ok "uploaded"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  warn "dry run — skipping the live HTTP check (files were not uploaded)"
else
  bad=()
  for f in "${EXPECTED[@]}"; do
    code="$(http_code "$BASE_URL/$MAJOR/$f")"
    printf '  %-34s %s\n' "$f" "$code"
    [ "$code" = "200" ] || bad+=("$f")
  done
  [ "${#bad[@]}" -eq 0 ] || die "${#bad[@]} installer(s) are not reachable under $BASE_URL/$MAJOR/."
  ok "all ${#EXPECTED[@]} installers return 200"
fi

# ── 5. refresh the standalone TRMASTER.DTA ──────────────────────────
step "5/8  Standalone TRMASTER.DTA"

if [ "$DB_CHANGED" -eq 0 ]; then
  ok "unchanged — nothing to upload"
else
  STAMP="$(date +%Y%m%d)"
  confirm "Replace $BASE_URL/TRMASTER.DTA (backup: TRMASTER.DTA.bak-$STAMP) ?"
  run ssh -n "$SERVER" \
    "test -f $DOCROOT/TRMASTER.DTA && cp -p $DOCROOT/TRMASTER.DTA $DOCROOT/TRMASTER.DTA.bak-$STAMP || true"
  ok "backed up existing copy to TRMASTER.DTA.bak-$STAMP"
  run rsync -av "$SHIPPED" "$SERVER:$DOCROOT/TRMASTER.DTA"

  if [ "$DRY_RUN" -eq 1 ]; then
    warn "dry run — skipping post-upload hash check"
  else
    curl -fsL --max-time 60 -o "$STAGE/dta/after.DTA" "$BASE_URL/TRMASTER.DTA" \
      || die "could not re-fetch $BASE_URL/TRMASTER.DTA after upload."
    [ "$(sha256 "$STAGE/dta/after.DTA")" = "$SHIPPED_SHA" ] \
      || die "live TRMASTER.DTA does not match the installer's copy after upload."
    ok "live copy now matches the installer byte for byte"
  fi
fi

# ── 6. repoint the site ─────────────────────────────────────────────
step "6/8  Repoint .htaccess + index.html"

# Capture the TRMASTER label before release.sh rewrites every date on the page,
# so it can be restored when the database did not actually change.
DTA_LINE_BEFORE="$(grep -n 'TRMASTER\.DTA — Callsign database' "$IDX" | head -1 || true)"

if [ "$DRY_RUN" -eq 1 ]; then
  warn "dry run — not running bin/release.sh"
else
  "$ROOT/bin/release.sh" "$VER" "$MONTH" >/dev/null \
    || die "bin/release.sh failed."
  ok "bin/release.sh applied"

  if [ "$DB_CHANGED" -eq 0 ] && [ -n "$DTA_LINE_BEFORE" ]; then
    old_text="${DTA_LINE_BEFORE#*:}"
    lineno="${DTA_LINE_BEFORE%%:*}"
    OLD="$old_text" LN="$lineno" perl -i -pe 's/^.*$/$ENV{OLD}/ if $. == $ENV{LN}' "$IDX"
    ok "restored the callsign-database label (DB unchanged this release)"
  fi

  printf '\n%s--- diff ---%s\n' "$B" "$Z"
  git -C "$ROOT" --no-pager diff -- public_html/.htaccess public_html/index.html
fi

# ── 7. commit + push ────────────────────────────────────────────────
step "7/8  Commit and ship"

if [ "$DRY_RUN" -eq 1 ]; then
  warn "dry run — not committing or pushing"
else
  confirm "Commit the diff above and push to main (this deploys to production)?"
  git -C "$ROOT" add public_html/.htaccess public_html/index.html
  msg_dta="TRMASTER.DTA refreshed (sha256 ${SHIPPED_SHA:0:16}…, identical to the installer's copy)."
  [ "$DB_CHANGED" -eq 0 ] && msg_dta="TRMASTER.DTA unchanged this release; its label was left as-is."
  git -C "$ROOT" commit -q -m "$(printf '%s\n' \
    "Release $VER ($MONTH)" \
    "" \
    "Repoint the download redirect at /$MAJOR/ and bump the displayed" \
    "version/date labels. Installers were uploaded to the host out-of-band." \
    "$msg_dta")"
  ok "committed $(git -C "$ROOT" rev-parse --short HEAD)"

  if [ "$NO_PUSH" -eq 1 ]; then
    warn "--no-push given: commit is local. Push to main when ready to deploy."
    exit 0
  fi

  git -C "$ROOT" push -q origin main || die "push failed."
  ok "pushed to origin/main — deploy workflow triggered"

  sleep 10
  RUN_ID="$(gh run list --repo "$SITE_REPO" --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null || true)"
  if [ -n "$RUN_ID" ]; then
    printf '  waiting for deploy run %s …\n' "$RUN_ID"
    gh run watch --repo "$SITE_REPO" "$RUN_ID" --exit-status --interval 10 >/dev/null 2>&1 \
      || die "the deploy workflow failed. See: gh run view --repo $SITE_REPO $RUN_ID --log-failed"
    ok "deploy workflow succeeded"
  else
    warn "could not find the workflow run; check the Actions tab manually"
  fi
fi

# ── 8. confirm live ─────────────────────────────────────────────────
step "8/8  Verify the live site"

if [ "$DRY_RUN" -eq 1 ]; then
  warn "dry run — nothing to verify"
  printf '\n%sDry run complete.%s Re-run without --dry-run to publish %s.\n' "$G" "$Z" "$VER"
  exit 0
fi

bad=()
for l in "" "${LANGS[@]/#/_}"; do
  loc="$(curl -sI --max-time 30 "$BASE_URL/download/tr4w_setup$l.exe" \
        | tr -d '\r' | awk 'tolower($1)=="location:"{print $2}')"
  printf '  %-12s %s\n' "${l:-main}" "${loc:-<none>}"
  case "$loc" in
    "$BASE_URL/$MAJOR/tr4w_setup_${VER}${l}.exe") ;;
    *) bad+=("tr4w_setup$l.exe") ;;
  esac
done
[ "${#bad[@]}" -eq 0 ] || die "${#bad[@]} download URL(s) do not redirect to $VER."
ok "all $(( ${#LANGS[@]} + 1 )) download URLs redirect to /$MAJOR/"

home="$(curl -fsL --max-time 30 "$BASE_URL/")"
printf '%s' "$home" | grep -q "$VER"   || die "homepage does not mention $VER."
printf '%s' "$home" | grep -q "$MONTH" || die "homepage does not mention $MONTH."
if printf '%s' "$home" | grep -q "$CUR_VER"; then
  warn "homepage still mentions the previous version $CUR_VER — check index.html"
else
  ok "homepage shows $VER · $MONTH with no stale $CUR_VER references"
fi

printf '\n%sRelease %s (%s) is live.%s\n' "$G" "$VER" "$MONTH" "$Z"
