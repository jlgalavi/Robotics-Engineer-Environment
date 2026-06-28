#!/usr/bin/env bash
set -u

ok() { printf '✓ %s\n' "$1"; }
warn() { printf '⚠ %s\n' "$1"; }

command -v wezterm >/dev/null 2>&1 && ok "WezTerm instalado" || warn "WezTerm no encontrado"
command -v fzf >/dev/null 2>&1 && ok "fzf instalado" || warn "fzf no encontrado"
[[ -f /opt/ros/jazzy/setup.bash ]] && ok "ROS 2 Jazzy disponible" || warn "/opt/ros/jazzy/setup.bash no existe"
[[ -e "$HOME/.config/wezterm" || -L "$HOME/.config/wezterm" ]] && ok "Configuración de WezTerm presente" || warn "Configuración de WezTerm ausente"
[[ -L "$HOME/.config/wezterm" ]] && ok "WezTerm usa un enlace simbólico" || warn "WezTerm no usa un enlace simbólico"

if command -v fc-match >/dev/null 2>&1; then
  found=""
  for family in "JetBrains Mono" "Cascadia Code" "Maple Mono"; do
    match="$(fc-match -f '%{family}\n' "$family" 2>/dev/null | head -n1)"
    if [[ "$match" == *"$family"* ]]; then found="$match"; break; fi
  done
  [[ -n "$found" ]] && ok "Fuente compatible: $found" || warn "No se encontró JetBrains Mono, Cascadia Code ni Maple Mono"
else
  warn "fc-match no está instalado"
fi
