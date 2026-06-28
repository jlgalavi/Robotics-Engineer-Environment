#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$HOME/.config/robotics-dev-environment/backups/$timestamp"
mkdir -p "$backup_dir"

if [[ -e "$HOME/.config/wezterm" || -L "$HOME/.config/wezterm" ]]; then
  cp -a "$HOME/.config/wezterm" "$backup_dir/wezterm"
  echo "Backup de WezTerm: $backup_dir/wezterm"
fi
if [[ -f "$HOME/.bashrc" ]]; then
  cp -a "$HOME/.bashrc" "$backup_dir/bashrc"
  echo "Backup de Bash: $backup_dir/bashrc"
fi

printf '%s\n' "$backup_dir" > "$HOME/.config/robotics-dev-environment/last_backup"
echo "Backup completado: $backup_dir"
