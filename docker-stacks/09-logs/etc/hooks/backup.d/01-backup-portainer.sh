#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_HOME}/backup/logs"
BACKUP_VOLUME="portainer-logs"

"${SIMVA_HOME}/simva" stop $CURRENT_STACK
echo "💾 Creating new backup..."
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME"
echo "✅ Backup completed!"