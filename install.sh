#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$PWD" != "$ROOT_DIR" ]]; then
  echo "Error: run this script from the project root: $ROOT_DIR" >&2
  exit 1
fi

"$ROOT_DIR/scripts/backup_existing.sh"
"$ROOT_DIR/scripts/link_configs.sh"

cat <<'EOF'

Provisional installation completed.
Next steps:
  1. Run ./scripts/healthcheck.sh
  2. Restart WezTerm and review its configuration
  3. Review bash/bashrc manually; your ~/.bashrc was not modified
EOF
