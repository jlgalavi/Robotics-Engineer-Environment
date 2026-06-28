#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$PWD" != "$ROOT_DIR" ]]; then
  echo "Error: ejecuta este script desde la raíz del proyecto: $ROOT_DIR" >&2
  exit 1
fi

"$ROOT_DIR/scripts/backup_existing.sh"
"$ROOT_DIR/scripts/link_configs.sh"

cat <<'EOF'

Instalación provisional completada.
Próximos pasos:
  1. Ejecuta ./scripts/healthcheck.sh
  2. Reinicia WezTerm y revisa su configuración
  3. Revisa bash/bashrc manualmente; tu ~/.bashrc no ha sido modificado
EOF
