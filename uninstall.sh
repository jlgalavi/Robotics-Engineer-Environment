#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config/wezterm"

if [[ -L "$TARGET" && "$(readlink -f -- "$TARGET")" == "$(readlink -f -- "$ROOT_DIR/wezterm")" ]]; then
  unlink "$TARGET"
  echo "Enlace $TARGET eliminado. Los backups no se han tocado."
  echo "Restaura manualmente la copia deseada desde ~/.config/robotics-dev-environment/backups/."
else
  echo "No se ha modificado $TARGET: no es el enlace gestionado por este proyecto."
fi
