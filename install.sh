#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_URL="${RDE_REPOSITORY_URL:-https://github.com/jlgalavi/Robotics-Engineer-Environment.git}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
MANAGED_ROOT="${RDE_MANAGED_ROOT:-$DATA_HOME/rde}"

die() { printf 'Error: %s\n' "$1" >&2; exit "${2:-1}"; }
validate_platform() {
  [[ "${RDE_SKIP_PLATFORM_CHECK:-false}" == true ]] && return
  [[ -r /etc/os-release ]] || die "Cannot identify the operating system."
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == ubuntu && "${VERSION_ID:-}" == 24.04 ]] || die "RDE v1 supports Ubuntu 24.04; detected ${ID:-unknown} ${VERSION_ID:-unknown}."
}
prepare_bootstrap_dependencies() {
  local required=(ca-certificates curl gnupg git) missing=() package
  for package in "${required[@]}"; do
    dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'ok installed' || missing+=("$package")
  done
  [[ ${#missing[@]} -eq 0 ]] && return 0
  command -v sudo >/dev/null 2>&1 || die "sudo is required to install bootstrap dependencies: ${missing[*]}"
  printf 'Installing bootstrap dependencies: %s\n' "${missing[*]}"
  sudo apt-get update
  sudo apt-get install -y "${missing[@]}"
}
latest_release() {
  { git ls-remote --tags --refs "$REPOSITORY_URL" 'v*' 2>/dev/null |
    awk -F/ '{print $3}' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1; } || true
}

validate_platform
command -v dpkg-query >/dev/null 2>&1 || die "dpkg-query is required; this bootstrap only supports Ubuntu 24.04."
command -v apt-get >/dev/null 2>&1 || die "apt-get is required; this bootstrap only supports Ubuntu 24.04."
prepare_bootstrap_dependencies
command -v git >/dev/null 2>&1 || die "Git is unavailable after installing bootstrap dependencies."
git ls-remote "$REPOSITORY_URL" HEAD >/dev/null 2>&1 || die "The RDE repository is not reachable: $REPOSITORY_URL"
version="${RDE_VERSION:-$(latest_release)}"
if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  die "No stable RDE release was found. install.sh requires a vMAJOR.MINOR.PATCH tag.
This repository has not published its first stable release yet.
From the development checkout, use './rde try' or './rde install' instead."
fi

if [[ -e "$MANAGED_ROOT" && ! -d "$MANAGED_ROOT/.git" ]]; then
  die "$MANAGED_ROOT exists but is not an RDE Git checkout. Move it aside and retry."
fi
if [[ -d "$MANAGED_ROOT/.git" ]]; then
  [[ -z "$(git -C "$MANAGED_ROOT" status --porcelain)" ]] || die "$MANAGED_ROOT has local changes; refusing to overwrite them."
  git -C "$MANAGED_ROOT" remote set-url origin "$REPOSITORY_URL"
  git -C "$MANAGED_ROOT" fetch --tags --force origin
else
  mkdir -p "$(dirname "$MANAGED_ROOT")"
  git clone --filter=blob:none --no-checkout "$REPOSITORY_URL" "$MANAGED_ROOT"
fi
git -C "$MANAGED_ROOT" checkout --detach "$version"

printf 'RDE %s prepared in %s\n' "$version" "$MANAGED_ROOT"
exec "$MANAGED_ROOT/rde" install "$@"
