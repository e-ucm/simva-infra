#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_HOME}/backup/minio"
BACKUP_VOLUME="minio_data"

# Check if the container is running
source "${SIMVA_HOME}/bin/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="minio"
_stop_docker_container_if_running

echo "💾 Creating new backup..."
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME" #TODO ONLY COMPACTED DATA
echo "✅ Backup completed!"