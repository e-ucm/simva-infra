#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_HOME}/backup/simva"

# Check if the container is running
source "${SIMVA_HOME}/bin/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="simva-trace-allocator"
_stop_docker_container_if_running
export RUN_IN_CONTAINER_NAME="simva-front"
_stop_docker_container_if_running
export RUN_IN_CONTAINER_NAME="simva-api"
_stop_docker_container_if_running
export RUN_IN_CONTAINER_NAME="mongodb"
_stop_docker_container_if_running

"${SIMVA_HOME}/simva" stop $CURRENT_STACK
BACKUP_VOLUME="simva_mongodb_data"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_VOLUME"
"${SIMVA_HOME}/bin/volumectl.sh" restore $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME" #TODO VIA OTHER METHOD
BACKUP_TRACE_ALLOCATOR_VOLUME="simva_trace_allocator_data"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_TRACE_ALLOCATOR_VOLUME"
"${SIMVA_HOME}/bin/volumectl.sh" restore $BACKUP_TRACE_ALLOCATOR_VOLUME "$BACKUP_DIR/$BACKUP_TRACE_ALLOCATOR_VOLUME"
BACKUP_STORAGE_VOLUME="simva_storage_data"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_STORAGE_VOLUME"
"${SIMVA_HOME}/bin/volumectl.sh" restore $BACKUP_STORAGE_VOLUME "$BACKUP_DIR/$BACKUP_STORAGE_VOLUME"
echo "✅ Restore completed successfully."