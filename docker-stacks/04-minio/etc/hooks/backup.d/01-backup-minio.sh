#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

BACKUP_DIR="${SIMVA_BACKUP_HOME}/minio"
BACKUP_VOLUME="minio_data"

# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
if [[ "${SIMVA_RUSTFS_ENABLE:-false}" == "true" ]]; then
    export RUN_IN_CONTAINER_NAME="rustfs"
else 
    export RUN_IN_CONTAINER_NAME="minio"
fi
_stop_docker_container_if_running

echo "💾 Creating new backup..."
"${SIMVA_BIN_HOME}/volumectl.sh" backup $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME" $(cat "${SIMVA_BACKUP_HOME}/${STACK_NAME}/.timestamp") #TODO ONLY COMPACTED DATA
echo "✅ Backup completed!"