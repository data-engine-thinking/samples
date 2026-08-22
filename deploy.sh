#!/usr/bin/env bash
# deploy.sh — Deploy the Data Engine Thinking samples site to
#             docs.dataenginethinking.com (all-inkl).
#
# Usage:  ./deploy.sh                     (dry run — shows changes, uploads nothing)
#         ./deploy.sh --go                (real deployment)
#         ./deploy.sh --go --skip-build   (deploy the existing dist/ as-is)
#         ./deploy.sh --help              (help)
#
# This mirrors websites/training/deploy.sh in the `collaboration` repo, with one
# difference: that site is hand-written HTML that ships straight from the repo,
# whereas this one is an Astro build, so `dist/` is generated first and only
# `dist/` is uploaded.

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
# Each value can be overridden from the environment, so a staging target does
# not need an edit here:  DEPLOY_TARGET_DIR=PrdDomains/staging.example ./deploy.sh
REMOTE_HOST="${DEPLOY_REMOTE_HOST:-allinkl}"
BASE_PATH="${DEPLOY_BASE_PATH:-/www/htdocs/v146780}"
TARGET_DIR="${DEPLOY_TARGET_DIR:-PrdDomains/docs.dataenginethinking.com}"

# Prefer whatever rsync is on PATH; fall back to the Homebrew one. macOS ships a
# very old rsync, so the Homebrew build is the one that has been used for these
# deploys.
RSYNC_BIN="${RSYNC_BIN:-$(command -v rsync || echo /opt/homebrew/bin/rsync)}"

# Refuse to deploy a dist/ that looks incomplete. Because the upload runs with
# --delete, syncing a broken or half-written build would remove the live site.
# The site is ~100 pages; anything under this is treated as a failed build.
MIN_HTML_FILES="${DEPLOY_MIN_HTML_FILES:-50}"
# ─────────────────────────────────────────────────────────────────────────────

REMOTE_DEST="${REMOTE_HOST}:${BASE_PATH}/${TARGET_DIR}/"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="${SCRIPT_DIR}/dist"

show_help() {
    cat <<'HELP'
Usage: ./deploy.sh [OPTIONS]

Deploy the Data Engine Thinking samples site to docs.dataenginethinking.com.

Options:
  (none)         Dry run. Builds the site and shows what rsync would change,
                 but uploads nothing. This is the default on purpose.
  --go           Actually upload.
  --skip-build   Reuse the existing dist/ instead of running `pnpm build`.
                 Only sensible directly after a build you have already checked.
  --help, -h     Show this help.

Environment overrides:
  DEPLOY_REMOTE_HOST       SSH host alias        (default: allinkl)
  DEPLOY_BASE_PATH         Remote base path      (default: /www/htdocs/v146780)
  DEPLOY_TARGET_DIR        Remote target dir     (default: PrdDomains/docs.dataenginethinking.com)
  RSYNC_BIN                rsync binary to use
  DEPLOY_MIN_HTML_FILES    Minimum pages in dist/ before upload is allowed (default: 50)

What gets deployed:
  dist/                    The built static site, and nothing else. Everything
                           in dist/ is generated, so the upload runs with
                           --delete to drop files removed since the last deploy.

After deploying, confirm what is actually live:
  curl -s https://docs.dataenginethinking.com | grep -o 'Astro v[0-9.]*'
HELP
    exit 0
}

DO_DEPLOY="no"
SKIP_BUILD="no"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --go)         DO_DEPLOY="yes" ;;
        --skip-build) SKIP_BUILD="yes" ;;
        --help|-h)    show_help ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use './deploy.sh --help' for help." >&2
            exit 1
            ;;
    esac
    shift
done

# rsync takes --dry-run unless --go was passed. Kept in an array so the empty
# case expands to no argument at all rather than an empty string.
RSYNC_MODE=(--dry-run)
if [[ "${DO_DEPLOY}" == "yes" ]]; then
    RSYNC_MODE=()
    echo "LIVE deployment to ${REMOTE_DEST}"
else
    echo "Dry run (nothing is uploaded). Use './deploy.sh --go' to deploy for real."
fi

if [[ ! -x "${RSYNC_BIN}" ]] && ! command -v "${RSYNC_BIN}" >/dev/null 2>&1; then
    echo "ERROR: rsync not found at '${RSYNC_BIN}'." >&2
    echo "Install rsync, or set RSYNC_BIN to its path." >&2
    exit 1
fi

# ── Build ────────────────────────────────────────────────────────────────────
if [[ "${SKIP_BUILD}" == "yes" ]]; then
    echo "Skipping build, reusing the existing dist/."
else
    echo "Building site..."
    ( cd "${SCRIPT_DIR}" && pnpm build )
fi

# ── Verify the build before letting rsync --delete near the live site ─────────
if [[ ! -d "${DIST_DIR}" ]]; then
    echo "ERROR: ${DIST_DIR} does not exist. Run a build first." >&2
    exit 1
fi

if [[ ! -f "${DIST_DIR}/index.html" ]]; then
    echo "ERROR: ${DIST_DIR}/index.html is missing — dist/ is not a complete build." >&2
    exit 1
fi

HTML_COUNT="$(find "${DIST_DIR}" -name '*.html' -type f | wc -l | tr -d ' ')"
if (( HTML_COUNT < MIN_HTML_FILES )); then
    echo "ERROR: only ${HTML_COUNT} HTML files in dist/, expected at least ${MIN_HTML_FILES}." >&2
    echo "Refusing to deploy — this looks like a failed or partial build." >&2
    echo "If the site genuinely got smaller, re-run with DEPLOY_MIN_HTML_FILES=<n>." >&2
    exit 1
fi

VERSION="$(git -C "${SCRIPT_DIR}" rev-parse --short HEAD 2>/dev/null || date +%Y%m%d%H%M)"
echo "Deploying ${HTML_COUNT} pages, commit ${VERSION}"

# ── Upload ───────────────────────────────────────────────────────────────────
# --chmod forces 755/644 on the way over. Build output can carry restrictive
# permissions, and without this Apache ends up unable to read the files.
"${RSYNC_BIN}" -avz --delete \
    "${RSYNC_MODE[@]}" \
    --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
    --exclude='.DS_Store' \
    "${DIST_DIR}/" \
    "${REMOTE_DEST}"

# ── Fix permissions (real deploys only) ──────────────────────────────────────
if [[ "${DO_DEPLOY}" == "yes" ]]; then
    echo ""
    echo "Setting permissions..."
    ssh "${REMOTE_HOST}" "
        cd ${BASE_PATH}/${TARGET_DIR} && \
        find . -type d -exec chmod 755 {} \; && \
        find . -type f -exec chmod 644 {} \;
    "
    echo "Permissions set (directories 755, files 644)."

    echo ""
    echo "Deployment complete."
    echo "Verify what is live:"
    echo "  curl -s https://docs.dataenginethinking.com | grep -o 'Astro v[0-9.]*'"
else
    echo ""
    echo "Dry run finished. Check the output above."
    echo "To deploy for real:  ./deploy.sh --go"
fi
