#!/usr/bin/env bash
# Deploy the website source to the production server.
# rsync public_html/ -> server, skipping the gitignored binaries (installers, etc.).
# Safe: no --delete, so it only adds/updates. Pass -n for a dry run.
#
# CI-ONLY. Production is deployed exclusively by the GitHub Actions workflow
# (.github/workflows/deploy.yml) on push to main — GitHub is the single source
# of truth. This script intentionally has NO local default target: it refuses
# to run unless DEPLOY_DEST is set (only the workflow sets it), so it cannot be
# used to push a local working copy straight to the live host. The transport
# (key, known_hosts, port) is supplied via rsync's RSYNC_RSH env var.
set -euo pipefail

DRY=""
[ "${1:-}" = "-n" ] && DRY="-n"

if [ -z "${DEPLOY_DEST:-}" ]; then
  echo "error: DEPLOY_DEST is not set." >&2
  echo "Deploys run only via GitHub Actions (push to main), not from local machines." >&2
  exit 1
fi
DEST="$DEPLOY_DEST"

rsync -av $DRY \
  --exclude='*.exe' --exclude='*.gpg' --exclude='*.7z' --exclude='*.zip' \
  --exclude='TRMASTER.DTA' --exclude='TRMASTER.ASC' \
  --exclude='*.bak' --exclude='*~' --exclude='.DS_Store' \
  public_html/ "$DEST"
