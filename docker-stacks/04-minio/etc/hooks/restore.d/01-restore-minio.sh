#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_BACKUP_HOME}/minio"
BACKUP_VOLUME="minio_data"

# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="minio"
_stop_docker_container_if_running

echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_VOLUME"
"${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME"
echo "✅ Restore completed successfully."