#!/usr/bin/env bash

RDE_BASH_BEGIN="# >>> RDE managed block >>>"
RDE_BASH_END="# <<< RDE managed block <<<"

rde_remove_bash_block() {
  local file=$1 temporary
  temporary="$file.rde.$$"
  [[ -f "$file" ]] || return 0
  awk -v begin="$RDE_BASH_BEGIN" -v end="$RDE_BASH_END" '
    $0 == begin { managed=1; next }
    $0 == end { managed=0; next }
    !managed { print }
  ' "$file" > "$temporary" && mv "$temporary" "$file"
}
component_bash_check() { grep -Fqx "$RDE_BASH_BEGIN" "$HOME/.bashrc" 2>/dev/null; }
component_bash_plan() { echo "manage ~/.bashrc block"; }
component_bash_install() {
  local bashrc="$HOME/.bashrc"
  touch "$bashrc"; rde_backup_path "$bashrc" bashrc
  rde_remove_bash_block "$bashrc"
  cat >> "$bashrc" <<EOF
$RDE_BASH_BEGIN
if [[ -r "$RDE_ROOT/bash/bashrc" ]]; then
  source "$RDE_ROOT/bash/bashrc"
fi
$RDE_BASH_END
EOF
  rde_state_set bashrc "$bashrc"; rde_ok "Bash integration enabled"
}
component_bash_update() { component_bash_install; }
component_bash_uninstall() {
  local bashrc; bashrc=$(rde_state_get bashrc); [[ -n "$bashrc" ]] || bashrc="$HOME/.bashrc"
  component_bash_check || { rde_warn "The managed Bash block is missing; no Bash content was removed."; return 0; }
  rde_remove_bash_block "$bashrc"; rde_restore_backup bashrc "$bashrc"
}
component_bash_doctor() {
  local failed=0 module
  component_bash_check && rde_ok "Bash managed block found" || { rde_warn "Bash managed block missing"; failed=1; }
  bash -n "$RDE_ROOT/bash/bashrc" || failed=1
  for module in "$RDE_ROOT"/bash/modules/*.sh; do bash -n "$module" || failed=1; done
  [[ $failed -eq 0 ]] && rde_ok "Bash configuration syntax valid"
  return "$failed"
}

component_git_check() { command -v git >/dev/null 2>&1; }
component_git_plan() { echo "install git if missing; keep identity untouched"; }
component_git_install() { rde_install_package git; }
component_git_update() { component_git_install; }
component_git_uninstall() { rde_info "Git configuration and package preserved."; }
component_git_doctor() { component_git_check && rde_ok "Git available" || { rde_warn "Git not found"; return 1; }; }

component_fzf_check() { command -v fzf >/dev/null 2>&1; }
component_fzf_plan() { echo "install fzf"; }
component_fzf_install() { rde_install_package fzf; }
component_fzf_update() { component_fzf_install; }
component_fzf_uninstall() { rde_info "fzf package preserved."; }
component_fzf_doctor() { component_fzf_check && rde_ok "fzf available" || { rde_warn "fzf not found"; return 1; }; }

component_wezterm_check() { command -v wezterm >/dev/null 2>&1; }
component_wezterm_plan() { echo "install WezTerm and manage ~/.config/wezterm"; }
component_wezterm_install() {
  rde_setup_wezterm_repo || { rde_error "Could not configure the official WezTerm apt repository."; return 1; }
  rde_install_package wezterm || { rde_error "WezTerm could not be installed from its official apt repository."; return 1; }
  local target="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm" source="$RDE_ROOT/wezterm"
  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then rde_ok "WezTerm configuration already linked"; return 0; fi
  if [[ -e "$target" || -L "$target" ]]; then rde_backup_path "$target" wezterm; mv "$target" "$target.rde-previous-$(date +%s)"; fi
  ln -s "$source" "$target"; rde_state_set wezterm_link "$target"; rde_ok "WezTerm configuration linked"
}
component_wezterm_update() { component_wezterm_install; }
component_wezterm_uninstall() {
  local target source="$RDE_ROOT/wezterm"; target=$(rde_state_get wezterm_link); [[ -n "$target" ]] || target="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm"
  if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then unlink "$target"; else rde_warn "$target is not an RDE-managed link; it was preserved."; fi
  rde_restore_backup wezterm "$target"
}
component_wezterm_doctor() {
  local failed=0 target="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm"
  component_wezterm_check && rde_ok "WezTerm available" || { rde_warn "WezTerm not found"; failed=1; }
  [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$RDE_ROOT/wezterm")" ]] && rde_ok "WezTerm configuration managed" || { rde_warn "WezTerm configuration link is not managed"; failed=1; }
  if [[ $failed -eq 0 ]]; then
    wezterm --config-file "$target/wezterm.lua" show-keys --lua >/dev/null 2>&1 && rde_ok "WezTerm configuration loads correctly" || { rde_warn "WezTerm configuration could not be loaded"; failed=1; }
  fi
  return "$failed"
}

component_fonts_check() { command -v fc-match >/dev/null 2>&1 && fc-match -f '%{family}' 'JetBrains Mono' 2>/dev/null | grep -qi 'JetBrains Mono'; }
component_fonts_plan() { echo "install JetBrains Mono, Noto Color Emoji, and fontconfig"; }
component_fonts_install() { rde_install_package fontconfig && rde_install_package fonts-jetbrains-mono && rde_install_package fonts-noto-color-emoji && fc-cache -f >/dev/null 2>&1; }
component_fonts_update() { component_fonts_install; }
component_fonts_uninstall() { rde_info "Font packages preserved."; }
component_fonts_doctor() { component_fonts_check && rde_ok "JetBrains Mono available" || { rde_warn "JetBrains Mono not found"; return 1; }; }
