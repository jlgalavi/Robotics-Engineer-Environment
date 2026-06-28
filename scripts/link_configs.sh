#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT_DIR/wezterm"
TARGET="$HOME/.config/wezterm"
STATE_DIR="$HOME/.config/robotics-dev-environment"

mkdir -p "$HOME/.config"
if [[ ! -s "$STATE_DIR/last_backup" ]]; then
  echo "Error: no hay constancia de un backup. Ejecuta scripts/backup_existing.sh primero." >&2
  exit 1
fi

if [[ -L "$TARGET" && "$(readlink -f -- "$TARGET")" == "$(readlink -f -- "$SOURCE")" ]]; then
  echo "WezTerm ya apunta a $SOURCE"
elif [[ -e "$TARGET" || -L "$TARGET" ]]; then
  previous="$TARGET.previous.$(date +%Y%m%d-%H%M%S)"
  mv -- "$TARGET" "$previous"
  ln -s "$SOURCE" "$TARGET"
  echo "Configuración anterior conservada en: $previous"
  echo "Enlace creado: $TARGET -> $SOURCE"
else
  ln -s "$SOURCE" "$TARGET"
  echo "Enlace creado: $TARGET -> $SOURCE"
fi

echo "~/.bashrc no se ha modificado. Compara bash/bashrc y modularízalo manualmente cuando estés listo."
