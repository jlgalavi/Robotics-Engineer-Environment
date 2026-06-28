#!/usr/bin/env bash
set -u

ok() { printf '✓ %s\n' "$1"; }
warn() { printf '⚠ %s\n' "$1"; }

command -v wezterm >/dev/null 2>&1 && ok "WezTerm installed" || warn "WezTerm not found"
command -v fzf >/dev/null 2>&1 && ok "fzf installed" || warn "fzf not found"
[[ -f /opt/ros/jazzy/setup.bash ]] && ok "ROS 2 Jazzy available" || warn "/opt/ros/jazzy/setup.bash does not exist"
[[ -e "$HOME/.config/wezterm" || -L "$HOME/.config/wezterm" ]] && ok "WezTerm configuration found" || warn "WezTerm configuration not found"
[[ -L "$HOME/.config/wezterm" ]] && ok "WezTerm uses a symbolic link" || warn "WezTerm does not use a symbolic link"

if command -v fc-match >/dev/null 2>&1; then
  found=""
  for family in "JetBrains Mono" "Cascadia Code" "Maple Mono"; do
    match="$(fc-match -f '%{family}\n' "$family" 2>/dev/null | head -n1)"
    if [[ "$match" == *"$family"* ]]; then found="$match"; break; fi
  done
  [[ -n "$found" ]] && ok "Compatible font: $found" || warn "JetBrains Mono, Cascadia Code, and Maple Mono were not found"
else
  warn "fc-match is not installed"
fi
