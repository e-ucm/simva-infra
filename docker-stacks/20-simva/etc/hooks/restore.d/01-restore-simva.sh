#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

BACKUP_DIR="${SIMVA_BACKUP_HOME}/simva"

# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
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
if [[ -d "$BACKUP_DIR/$BACKUP_VOLUME" ]]; then
    echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_VOLUME"
    "${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME"
fi
if [[ -d "$BACKUP_DIR/sqlite" ]]; then
    echo "🕐 Restoring from backup: $BACKUP_DIR/sqlite"
    # Remove existing sqlite db file if it exists to avoid mkdir conflict during extraction
    if docker volume inspect "simva_sqlite_data" >/dev/null 2>&1; then
        docker run --rm -v "simva_sqlite_data":/dest alpine sh -c "rm -rf /dest/${SIMVA_API_SQLITE_DB:-simva}_data.db" 2>/dev/null || true
    fi
    "${SIMVA_BIN_HOME}/volumectl.sh" copylv $BACKUP_DIR/sqlite "simva_sqlite_data" "${SIMVA_API_SQLITE_DB:-simva}_data.db" "${SIMVA_API_SQLITE_DB:-simva}_data.db" true
fi
BACKUP_TRACE_ALLOCATOR_VOLUME="simva_trace_allocator_data"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_TRACE_ALLOCATOR_VOLUME"
"${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_TRACE_ALLOCATOR_VOLUME "$BACKUP_DIR/$BACKUP_TRACE_ALLOCATOR_VOLUME"
BACKUP_STORAGE_VOLUME="simva_storage_data"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_STORAGE_VOLUME"
"${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_STORAGE_VOLUME "$BACKUP_DIR/$BACKUP_STORAGE_VOLUME"
echo "✅ Restore completed successfully."