#!/usr/bin/env bash
# Heuristic check for data that should be reviewed before publishing.
# This intentionally has no dependencies beyond Bash and ripgrep.
set -uo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

if ! command -v rg >/dev/null 2>&1; then
    printf 'Error: ripgrep (rg) is required for this check.\n' >&2
    exit 2
fi

cd "$ROOT_DIR" || exit 1

# Exclude Git internals, binary assets, and this script (which contains the
# detection expressions themselves). Review every reported match manually.
common_args=(
    --line-number --hidden --no-ignore --ignore-case
    --glob '!.git/**'
    --glob '!wezterm/backgrounds/**'
    --glob '!scripts/check-public-safety.sh'
)

status=0
run_check() {
    local label="$1"
    shift

    local matches
    matches=$(rg "${common_args[@]}" "$@" . 2>/dev/null) || {
        [[ $? -eq 1 ]] && return 0
        printf 'Check failed: %s\n' "$label" >&2
        status=2
        return
    }

    if [[ -n "$matches" ]]; then
        printf '\n[%s]\n%s\n' "$label" "$matches"
        [[ $status -eq 0 ]] && status=1
    fi
}

run_check 'personal paths or email addresses' \
    -e '/(home|Users)/[A-Za-z0-9._-]+/' \
    -e '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'
run_check 'private keys or credential assignments' \
    -e 'BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY' \
    -e '(api[_-]?key|access[_-]?token|password|passwd)[[:space:]]*[:=]'
# SSH config convention uses `Host` / `HostName`. Case-sensitive matching
# avoids confusing the ordinary `hostname` command with a host declaration.
run_check 'SSH host entries' --case-sensitive \
    -e '^[[:space:]]*Host(Name)?[[:space:]]+'
run_check 'IPv4 addresses' -e '(^|[^0-9])([0-9]{1,3}\.){3}[0-9]{1,3}([^0-9]|$)'

if [[ $status -eq 0 ]]; then
    printf 'Public-safety scan passed: no obvious sensitive patterns found.\n'
else
    printf '\nReview the matches above before publishing.\n' >&2
fi

exit "$status"
