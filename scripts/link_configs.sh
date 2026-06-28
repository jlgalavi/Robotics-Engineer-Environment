#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT_DIR/wezterm"
TARGET="$HOME/.config/wezterm"
STATE_DIR="$HOME/.config/robotics-dev-environment"

mkdir -p "$HOME/.config"
if [[ ! -s "$STATE_DIR/last_backup" ]]; then
  echo "Error: no backup record was found. Run scripts/backup_existing.sh first." >&2
  exit 1
fi

if [[ -L "$TARGET" && "$(readlink -f -- "$TARGET")" == "$(readlink -f -- "$SOURCE")" ]]; then
  echo "WezTerm already points to $SOURCE"
elif [[ -e "$TARGET" || -L "$TARGET" ]]; then
  previous="$TARGET.previous.$(date +%Y%m%d-%H%M%S)"
  mv -- "$TARGET" "$previous"
  ln -s "$SOURCE" "$TARGET"
  echo "Previous configuration preserved at: $previous"
  echo "Link created: $TARGET -> $SOURCE"
else
  ln -s "$SOURCE" "$TARGET"
  echo "Link created: $TARGET -> $SOURCE"
fi

echo "~/.bashrc was not modified. Test bash/bashrc and opt in manually when ready."
