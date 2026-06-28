#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.config/wezterm"

if [[ -L "$TARGET" && "$(readlink -f -- "$TARGET")" == "$(readlink -f -- "$ROOT_DIR/wezterm")" ]]; then
  unlink "$TARGET"
  echo "Link $TARGET removed. Backups were left untouched."
  echo "Restore the desired copy manually from ~/.config/robotics-dev-environment/backups/."
else
  echo "$TARGET was not modified because it is not the link managed by this project."
fi
