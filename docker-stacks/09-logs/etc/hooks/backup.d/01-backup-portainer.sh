#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

BACKUP_DIR="${SIMVA_BACKUP_HOME}/logs"
BACKUP_VOLUME="portainer-logs"

"${SIMVA_HOME}/simva" stop $CURRENT_STACK
echo "💾 Creating new backup..."
"${SIMVA_BIN_HOME}/volumectl.sh" backup $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME"
echo "✅ Backup completed!"