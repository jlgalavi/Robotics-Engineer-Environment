#!/usr/bin/env bash

RDE_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/robotics-dev-environment"
RDE_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}/rde"
RDE_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
RDE_BIN_HOME="${RDE_BIN_HOME:-$HOME/.local/bin}"
RDE_STATE_FILE="$RDE_STATE_HOME/state"
RDE_BACKUP_ROOT="$RDE_CONFIG_HOME/backups"
RDE_COMPONENT_NAMES="bash git fzf wezterm fonts"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  RDE_BOLD=$'\033[1m'; RDE_RED=$'\033[31m'; RDE_GREEN=$'\033[32m'; RDE_YELLOW=$'\033[33m'; RDE_RESET=$'\033[0m'
else
  RDE_BOLD="" RDE_RED="" RDE_GREEN="" RDE_YELLOW="" RDE_RESET=""
fi

rde_info() { printf '%s\n' "$*"; }
rde_ok() { printf '%s✓%s %s\n' "$RDE_GREEN" "$RDE_RESET" "$*"; }
rde_warn() { printf '%s!%s %s\n' "$RDE_YELLOW" "$RDE_RESET" "$*" >&2; }
rde_error() { printf '%sError:%s %s\n' "$RDE_RED" "$RDE_RESET" "$*" >&2; }
rde_die() { local message=$1 code=${2:-1}; rde_error "$message"; exit "$code"; }
rde_is_tty() { [[ -t 0 && -t 1 ]]; }
rde_require_tty() { rde_is_tty || rde_die "$1" 2; }
rde_confirm() {
  [[ "$RDE_ASSUME_YES" == true ]] && return 0
  rde_require_tty "$1 Use --yes for non-interactive execution."
  local answer; read -r -p "$1 [y/N] " answer
  [[ "$answer" == y || "$answer" == Y || "$answer" == yes || "$answer" == YES ]]
}

rde_platform_check() {
  [[ "${RDE_SKIP_PLATFORM_CHECK:-false}" == true ]] && return 0
  [[ -r /etc/os-release ]] || rde_die "Cannot identify this operating system. Ubuntu 24.04 is required." 1
  local id version
  id=$(sed -n 's/^ID=//p' /etc/os-release | tr -d '"')
  version=$(sed -n 's/^VERSION_ID=//p' /etc/os-release | tr -d '"')
  [[ "$id" == ubuntu && "$version" == 24.04 ]] || rde_die "Unsupported platform: $id $version. RDE v1 supports Ubuntu 24.04." 1
}

rde_prepare_state() {
  mkdir -p "$RDE_STATE_HOME" "$RDE_CONFIG_HOME" "$RDE_BACKUP_ROOT"; touch "$RDE_STATE_FILE"; chmod 600 "$RDE_STATE_FILE"
  grep -q $'^schema\t' "$RDE_STATE_FILE" || printf 'schema\t1\n' >> "$RDE_STATE_FILE"
  [[ "$(awk -F '\t' '$1 == "schema" {print $2}' "$RDE_STATE_FILE")" == 1 ]] || rde_die "This state file was created by a newer RDE version." 1
}
rde_state_get() { awk -F '\t' -v key="$1" '$1 == key { value=$2 } END { print value }' "$RDE_STATE_FILE" 2>/dev/null; }
rde_state_set() {
  local key=$1 value=${2//$'\n'/} temporary
  temporary="$RDE_STATE_FILE.tmp.$$"
  awk -F '\t' -v key="$key" '$1 != key' "$RDE_STATE_FILE" > "$temporary" 2>/dev/null || true
  printf '%s\t%s\n' "$key" "$value" >> "$temporary"
  chmod 600 "$temporary"; mv "$temporary" "$RDE_STATE_FILE"
}
rde_list_add() {
  local key=$1 item=$2 current result="" entry
  current=$(rde_state_get "$key")
  for entry in ${current//,/ }; do [[ "$entry" == "$item" ]] || result="${result:+$result,}$entry"; done
  result="${result:+$result,}$item"; rde_state_set "$key" "$result"
}
rde_list_remove() {
  local key=$1 item=$2 current result="" entry
  current=$(rde_state_get "$key")
  for entry in ${current//,/ }; do [[ "$entry" == "$item" ]] || result="${result:+$result,}$entry"; done
  rde_state_set "$key" "$result"
}
rde_component_activate() { rde_list_add components "$1"; }
rde_component_deactivate() { rde_list_remove components "$1"; }
rde_component_active() { [[ ",$(rde_state_get components)," == *",$1,"* ]]; }

rde_backup_start() {
  RDE_CURRENT_BACKUP="$RDE_BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)-$$"
  mkdir -p "$RDE_CURRENT_BACKUP"
  rde_state_set last_backup "$RDE_CURRENT_BACKUP"
}
rde_backup_path() {
  local source=$1 name=$2
  [[ -n "${RDE_CURRENT_BACKUP:-}" ]] || rde_backup_start
  if [[ -e "$source" || -L "$source" ]]; then
    cp -a -- "$source" "$RDE_CURRENT_BACKUP/$name"
    rde_state_set "backup_$name" "$RDE_CURRENT_BACKUP/$name"
  fi
}
rde_restore_backup() {
  local name=$1 target=$2 backup
  [[ "$RDE_RESTORE" == true ]] || return 0
  backup=$(rde_state_get "backup_$name")
  [[ -e "$backup" || -L "$backup" ]] || { rde_warn "No backup available for $target"; return 0; }
  [[ ! -e "$target" && ! -L "$target" ]] || { rde_warn "Cannot restore $target because the destination exists."; return 0; }
  cp -a -- "$backup" "$target"; rde_ok "Restored $target"
}

rde_valid_component() { [[ " $RDE_COMPONENT_NAMES " == *" $1 "* ]]; }
rde_normalize_components() {
  local raw=${1//,/ } result="" item
  for item in $raw; do
    rde_valid_component "$item" || { rde_error "Unknown component: $item"; return 2; }
    [[ ",$result," == *",$item,"* ]] || result="${result:+$result,}$item"
  done
  printf '%s\n' "$result"
}
rde_profile_components() {
  local profile=$1 file line in_components=false result="" item
  file="$RDE_ROOT/profiles/$profile.yaml"
  [[ -r "$file" ]] || { rde_error "Unknown profile: $profile"; return 2; }
  while IFS= read -r line; do
    [[ "$line" =~ ^components:[[:space:]]*$ ]] && { in_components=true; continue; }
    if [[ "$in_components" == true && "$line" =~ ^[[:space:]]*-[[:space:]]*([a-z0-9_-]+)[[:space:]]*$ ]]; then
      item=${BASH_REMATCH[1]}; rde_valid_component "$item" || { rde_error "Invalid component '$item' in $file"; return 2; }
      result="${result:+$result,}$item"
    elif [[ "$in_components" == true && "$line" =~ ^[a-z] ]]; then in_components=false
    fi
  done < "$file"
  [[ -n "$result" ]] || { rde_error "Profile has no components: $profile"; return 2; }
  printf '%s\n' "$result"
}
rde_choose_profile() {
  printf 'Profiles: 1) minimal  2) default  3) full\n' >&2
  local choice; read -r -p "Choose [1-3]: " choice
  case "$choice" in 1) echo minimal;; 2) echo default;; 3) echo full;; *) rde_error "Invalid profile."; return 2;; esac
}
rde_edit_components() {
  local selected=$1 answer
  printf 'Selected components: %s\n' "$selected" >&2
  read -r -p "Enter a comma-separated replacement, or press Enter to keep it: " answer
  [[ -n "$answer" ]] && rde_normalize_components "$answer" || printf '%s\n' "$selected"
}

rde_print_install_plan() {
  local component
  printf '\n%sInstallation plan%s\n' "$RDE_BOLD" "$RDE_RESET"
  printf '  Components: %s\n' "$1"
  for component in ${1//,/ }; do printf '  - %-8s %s\n' "$component" "$("component_${component}_plan")"; done
  printf '  Backups:    %s\n  System packages may require sudo.\n\n' "$RDE_BACKUP_ROOT"
}
rde_print_uninstall_plan() {
  printf '\n%sUninstall plan%s\n  Components: %s\n  Packages:   %s\n  Backups will be preserved.\n\n' "$RDE_BOLD" "$RDE_RESET" "$1" "$([[ "$RDE_PURGE_PACKAGES" == true ]] && echo 'remove RDE-installed packages' || echo 'keep')"
}
rde_current_version() {
  local exact
  exact=$(git -C "$RDE_ROOT" describe --tags --exact-match 2>/dev/null) && { printf '%s\n' "$exact"; return; }
  printf 'development\n'
}
rde_validate_version() { [[ "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; }
rde_latest_release() {
  local root=$1 tag
  tag=$(git -C "$root" ls-remote --tags --refs origin 'v*' 2>/dev/null | awk -F/ '{print $3}' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)
  [[ -n "$tag" ]] || { rde_error "No stable release tags were found."; return 1; }
  printf '%s\n' "$tag"
}
rde_install_launcher() {
  mkdir -p "$RDE_BIN_HOME"
  local target="$RDE_BIN_HOME/rde"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$RDE_ROOT/rde")" ]]; then
      rde_state_set launcher "$target"
      return 0
    fi
    rde_backup_path "$target" launcher-rde
    mv -- "$target" "$target.rde-previous-$(date +%s)"
  fi
  ln -sfn "$RDE_ROOT/rde" "$target"
  rde_state_set launcher "$target"
}
rde_remove_managed_installation() {
  local launcher expected_root="$RDE_DATA_HOME/rde"
  launcher=$(rde_state_get launcher)
  if [[ -n "$launcher" && -L "$launcher" && "$(readlink -f "$launcher")" == "$(readlink -f "$RDE_ROOT/rde")" ]]; then
    unlink "$launcher"
  fi
  if [[ "$RDE_ROOT" == "$expected_root" && -d "$RDE_ROOT/.git" ]]; then
    rde_info "Removing managed checkout: $RDE_ROOT"
    rm -rf -- "$RDE_ROOT"
  else
    rde_info "Development checkout preserved: $RDE_ROOT"
  fi
}
rde_rollback_new_components() {
  local components=$1 component old_restore=$RDE_RESTORE
  [[ -n "$components" ]] || return 0
  rde_warn "Rolling back configuration added by this run. Installed packages will be preserved."
  RDE_RESTORE=true
  for component in $components; do
    "component_${component}_uninstall" || rde_warn "Could not fully roll back $component"
    rde_component_deactivate "$component"
  done
  RDE_RESTORE=$old_restore
}

# shellcheck disable=SC2016 # dpkg-query, not Bash, expands ${Status}.
rde_package_installed() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'ok installed'; }
rde_install_package() {
  local package=$1
  rde_package_installed "$package" && { rde_ok "$package already installed"; return 0; }
  rde_info "Installing system package: $package"
  "${RDE_SUDO:-sudo}" "${RDE_APT_GET:-apt-get}" install -y "$package" || return
  rde_list_add packages "$package"
}
rde_setup_wezterm_repo() {
  [[ "${RDE_SKIP_WEZTERM_REPO:-false}" == true ]] && return 0
  local keyring=/usr/share/keyrings/wezterm-fury.gpg list=/etc/apt/sources.list.d/wezterm.list temp_dir
  if [[ -r "$keyring" && -r "$list" ]] && grep -Fq 'https://apt.fury.io/wez/' "$list"; then return 0; fi
  command -v curl >/dev/null 2>&1 || rde_install_package curl || return
  command -v gpg >/dev/null 2>&1 || rde_install_package gnupg || return
  temp_dir=$(mktemp -d)
  if ! curl -fsSL https://apt.fury.io/wez/gpg.key -o "$temp_dir/key"; then rm -rf "$temp_dir"; return 1; fi
  if ! gpg --batch --yes --dearmor -o "$temp_dir/wezterm-fury.gpg" "$temp_dir/key"; then rm -rf "$temp_dir"; return 1; fi
  printf '%s\n' 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' > "$temp_dir/wezterm.list"
  "${RDE_SUDO:-sudo}" install -m 0644 "$temp_dir/wezterm-fury.gpg" "$keyring" || { rm -rf "$temp_dir"; return 1; }
  "${RDE_SUDO:-sudo}" install -m 0644 "$temp_dir/wezterm.list" "$list" || { rm -rf "$temp_dir"; return 1; }
  rm -rf "$temp_dir"
  "${RDE_SUDO:-sudo}" "${RDE_APT_GET:-apt-get}" update || return
  rde_state_set wezterm_repository managed
}
rde_purge_recorded_packages() {
  local packages package
  packages=$(rde_state_get packages)
  [[ -n "$packages" ]] || { rde_info "No RDE-installed packages are recorded."; return 0; }
  rde_info "Packages recorded for removal: $packages"
  rde_confirm "Remove these packages?" || return 0
  for package in ${packages//,/ }; do
    "${RDE_SUDO:-sudo}" "${RDE_APT_GET:-apt-get}" remove -y "$package" || return
    rde_list_remove packages "$package"
  done
}
