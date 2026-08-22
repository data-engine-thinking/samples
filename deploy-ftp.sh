#!/usr/bin/env bash
# deploy-ftp.sh — Publish dist/ to docs.dataenginethinking.com over FTPS.
#
# This is the fallback transport for machines without rsync + SSH (deploy.sh is
# the preferred route where those exist). It needs only curl, which ships with
# Git Bash on Windows.
#
# Usage:  ./deploy-ftp.sh                     (dry run — builds, uploads nothing)
#         ./deploy-ftp.sh --go                (build and upload)
#         ./deploy-ftp.sh --go --skip-build   (upload the existing dist/)
#         ./deploy-ftp.sh --help
#
# Credentials live outside this repository — either in ~/.netrc (preferred) or
# in environment variables. See `./deploy-ftp.sh --help` for both forms.
#
#   export DET_FTP_HOST=ftp.your-host.example
#   ./deploy-ftp.sh            # dry run: no credentials needed, no connection
#   ./deploy-ftp.sh --go
#
# Whichever form is used, the values reach curl through a config file on stdin,
# so the password never appears in the process list where other users on the
# machine could read it.

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
FTP_HOST="${DET_FTP_HOST:-}"
FTP_USER="${DET_FTP_USER:-}"
FTP_PASS="${DET_FTP_PASS:-}"

# Where the password lives. If DET_FTP_PASS is not set, curl reads the
# credentials from this netrc file instead — that keeps the password out of the
# environment and out of your shell history. See --help for the file format.
NETRC_FILE="${DET_FTP_NETRC_FILE:-${HOME}/.netrc}"

# Remote directory the site lives in, relative to where the FTP login lands.
# Many hosting accounts drop you straight into the web root, in which case "/"
# is correct. Check the dry-run output before using --go.
FTP_PATH="${DET_FTP_PATH:-/}"

# Require TLS. Plain FTP sends the password in clear text; set DET_FTP_INSECURE=1
# only if the host genuinely cannot do FTPS, and rotate the password afterwards.
REQUIRE_TLS="${DET_FTP_INSECURE:-}"

MIN_HTML_FILES="${DEPLOY_MIN_HTML_FILES:-50}"
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="${SCRIPT_DIR}/dist"

show_help() {
    cat <<'HELP'
Usage: ./deploy-ftp.sh [OPTIONS]

Publish dist/ to docs.dataenginethinking.com over FTPS, using curl.
Use deploy.sh instead when rsync and SSH are available — it is faster and can
delete files that no longer exist (see the limitation below).

Options:
  (none)         Dry run. Builds, then lists what would be uploaded. No network
                 writes at all. This is the default on purpose.
  --go           Actually upload.
  --skip-build   Reuse the existing dist/ instead of running `pnpm build`.
  --plain        Use plain FTP instead of FTPS. Required if the host does not
                 offer FTPS; note the password is then sent in clear text.
  --help, -h     Show this help.

Where to put the credentials
----------------------------
Two options. The netrc file is preferred: the password stays out of the
environment, out of `ps`, and out of your shell history.

  1. netrc file (default: ~/.netrc, override with DET_FTP_NETRC_FILE)

       machine ftp.your-host.example
       login your-user
       password your-password

     Then lock it down:  chmod 600 ~/.netrc
     Only DET_FTP_HOST needs to be set; the script uses netrc automatically
     whenever DET_FTP_PASS is unset.

  2. Environment variables, for one-off or CI use:

       export DET_FTP_USER=your-user
       export DET_FTP_PASS='your-password'

     Prefix the command with a space in most shells to keep it out of history,
     and `unset DET_FTP_PASS` when finished.

Never put credentials in a file inside this repository.

Required environment:
  DET_FTP_HOST   FTP hostname

Optional environment:
  DET_FTP_USER   FTP username (needed only without netrc)
  DET_FTP_PASS   FTP password (if unset, the netrc file is used)
  DET_FTP_NETRC_FILE
                 Path to the netrc file (default: ~/.netrc)
  DET_FTP_PATH   Remote directory the site lives in (default: /)
  DET_FTP_INSECURE=1
                 Same as --plain.
  DEPLOY_MIN_HTML_FILES
                 Minimum pages in dist/ before upload is allowed (default: 50)

Limitation vs deploy.sh:
  FTP has no mirror-with-delete. Files removed from the site since the last
  upload are NOT deleted from the server; they are simply left behind. Pages
  are overwritten in place, so the live site stays correct, but stale files
  linger until removed by hand. deploy.sh (rsync --delete) does not have this
  problem.

After deploying, confirm what is live:
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
        --plain)      REQUIRE_TLS="1" ;;
        --help|-h)    show_help ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use './deploy-ftp.sh --help' for help." >&2
            exit 1
            ;;
    esac
    shift
done

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl not found." >&2
    exit 1
fi

# ── Build ────────────────────────────────────────────────────────────────────
if [[ "${SKIP_BUILD}" == "yes" ]]; then
    echo "Skipping build, reusing the existing dist/."
else
    echo "Building site..."
    ( cd "${SCRIPT_DIR}" && pnpm build )
fi

# ── Verify the build ─────────────────────────────────────────────────────────
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
    echo "Refusing to upload — this looks like a failed or partial build." >&2
    exit 1
fi

FILE_COUNT="$(find "${DIST_DIR}" -type f | wc -l | tr -d ' ')"
VERSION="$(git -C "${SCRIPT_DIR}" rev-parse --short HEAD 2>/dev/null || date +%Y%m%d%H%M)"

# Normalise the remote path to exactly one leading and one trailing slash.
REMOTE_PATH="/${FTP_PATH#/}"
REMOTE_PATH="${REMOTE_PATH%/}/"

SCHEME="ftps"
TLS_NOTE="FTPS (TLS required)"
if [[ -n "${REQUIRE_TLS}" ]]; then
    SCHEME="ftp"
    TLS_NOTE="plain FTP — password sent in clear text"
fi

echo ""
echo "Site:      ${FILE_COUNT} files (${HTML_COUNT} pages), commit ${VERSION}"
echo "Target:    ${SCHEME}://${FTP_HOST:-<DET_FTP_HOST unset>}${REMOTE_PATH}"
echo "Transport: ${TLS_NOTE}"

# ── Dry run stops here ───────────────────────────────────────────────────────
if [[ "${DO_DEPLOY}" != "yes" ]]; then
    echo ""
    echo "Dry run — nothing was uploaded and no connection was made."
    echo "Sample of what would be sent:"
    ( cd "${DIST_DIR}" && find . -type f | sed 's|^\./||' | sort | head -5 | sed "s|^|  ${REMOTE_PATH}|" )
    echo "  ... and $(( FILE_COUNT > 5 ? FILE_COUNT - 5 : 0 )) more"
    echo ""
    echo "Check the target path above is right, then:  ./deploy-ftp.sh --go"
    exit 0
fi

# ── Credentials (only needed for a real upload) ───────────────────────────────
USE_NETRC="no"
if [[ -z "${FTP_PASS}" ]]; then
    USE_NETRC="yes"
fi

missing=()
[[ -z "${FTP_HOST}" ]] && missing+=("DET_FTP_HOST")
if [[ "${USE_NETRC}" == "no" ]]; then
    [[ -z "${FTP_USER}" ]] && missing+=("DET_FTP_USER")
fi
if (( ${#missing[@]} > 0 )); then
    echo "ERROR: missing required environment: ${missing[*]}" >&2
    echo "See './deploy-ftp.sh --help'." >&2
    exit 1
fi

if [[ "${USE_NETRC}" == "yes" ]]; then
    if [[ ! -f "${NETRC_FILE}" ]]; then
        echo "ERROR: no password given and no netrc file at ${NETRC_FILE}." >&2
        echo "Either create that file (see './deploy-ftp.sh --help') or set DET_FTP_PASS." >&2
        exit 1
    fi
    # Warn if the file is group/world readable. Windows filesystems often report
    # permissions that do not mean much, so this is advisory rather than fatal.
    perms="$(stat -c '%a' "${NETRC_FILE}" 2>/dev/null || echo '')"
    if [[ -n "${perms}" && "${perms}" != "600" && "${perms}" != "400" ]]; then
        echo "Note: ${NETRC_FILE} has mode ${perms}; 600 is the safer choice (chmod 600)."
    fi
    echo "Credentials: ${NETRC_FILE}"
else
    echo "Credentials: DET_FTP_USER / DET_FTP_PASS from the environment"
fi

# ── Upload ───────────────────────────────────────────────────────────────────
# Everything goes to curl as a config file on stdin: it keeps the password out
# of the process list, and sidesteps command-line length limits that would bite
# with a few hundred upload arguments. curl reuses the one connection for all
# of them, which is far quicker than invoking curl per file.
echo ""
echo "Uploading ${FILE_COUNT} files..."

build_curl_config() {
    # Escape backslashes and double quotes for curl's config format.
    esc() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

    if [[ "${USE_NETRC}" == "yes" ]]; then
        printf 'netrc-file = "%s"\n' "$(esc "${NETRC_FILE}")"
    else
        printf 'user = "%s:%s"\n' "$(esc "${FTP_USER}")" "$(esc "${FTP_PASS}")"
    fi
    printf 'ftp-create-dirs\n'
    printf 'silent\n'
    printf 'show-error\n'
    printf 'fail\n'
    if [[ -z "${REQUIRE_TLS}" ]]; then
        printf 'ssl-reqd\n'
    fi

    ( cd "${DIST_DIR}" && find . -type f | sed 's|^\./||' | sort ) | while IFS= read -r rel; do
        printf 'upload-file = "%s"\n' "$(esc "${DIST_DIR}/${rel}")"
        printf 'url = "%s"\n' "$(esc "${SCHEME}://${FTP_HOST}${REMOTE_PATH}${rel}")"
    done
}

if build_curl_config | curl -K -; then
    echo "Upload complete."
    echo ""
    echo "Verify what is live:"
    echo "  curl -s https://docs.dataenginethinking.com | grep -o 'Astro v[0-9.]*'"
else
    status=$?
    echo "" >&2
    echo "ERROR: upload failed (curl exit ${status})." >&2
    echo "The site may be partially updated — re-run once the cause is fixed." >&2
    exit "${status}"
fi
