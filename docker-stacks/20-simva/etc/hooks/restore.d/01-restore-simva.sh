#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

BACKUP_DIR="${SIMVA_BACKUP_HOME}/simva"

# Flatten function: finds and extracts .db file from nested backup path
flatten_db() {
    local backup_tar="$1"
    local target_dir="$2"
    mkdir -p "$target_dir"
    tar -xzf "$backup_tar" -C "$target_dir" 2>/dev/null || true
    # Find the .db file, handling nested simva-data.db directories
    find "$target_dir" -name "*.db" -type f | head -1
}

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
if [[ -d "$BACKUP_DIR/$BACKUP_VOLUME" && -f "$BACKUP_DIR/$BACKUP_VOLUME/*.tar.gz" ]]; then  
    echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_VOLUME"
    "${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME"
fi
if [[ -d "$BACKUP_DIR/sqlite" ]]; then
    echo "🕐 Restoring from backup: $BACKUP_DIR/sqlite"
    FLATTEN_DIR="/tmp/simva_flatten"
    DB_BACKUP="$BACKUP_DIR/sqlite/simva_data.db.tar.gz"
    if [[ -f "$DB_BACKUP" ]]; then
        DB_FILE=$(flatten_db "$DB_BACKUP" "$FLATTEN_DIR")
        if [[ -n "$DB_FILE" && -f "$DB_FILE" ]]; then
            echo "📋 Extracted database: $DB_FILE"
            if docker volume inspect "simva_sqlite_data" >/dev/null 2>&1; then
                docker run --rm -v "simva_sqlite_data":/dest alpine sh -c "rm -rf /dest/${SIMVA_API_SQLITE_DB:-simva}_data.db" 2>/dev/null || true
            fi
            "${SIMVA_BIN_HOME}/volumectl.sh" copylv "$(dirname "$DB_FILE")" "simva_sqlite_data" "$(basename "$DB_FILE")" "${SIMVA_API_SQLITE_DB:-simva}_data.db"
        fi
    fi
fi
BACKUP_TRACE_ALLOCATOR_VOLUME="simva_trace_allocator_data"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_TRACE_ALLOCATOR_VOLUME"
"${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_TRACE_ALLOCATOR_VOLUME "$BACKUP_DIR/$BACKUP_TRACE_ALLOCATOR_VOLUME"
BACKUP_STORAGE_VOLUME="simva_storage_data"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_STORAGE_VOLUME"
"${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_STORAGE_VOLUME "$BACKUP_DIR/$BACKUP_STORAGE_VOLUME"
echo "✅ Restore completed successfully."