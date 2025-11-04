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

echo "💾 Creating new backup..."
BACKUP_VOLUME="simva_mongodb_data"
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME" #TODO VIA OTHER METHOD
BACKUP_TRACE_ALLOCATOR_VOLUME="simva_trace_allocator_data"
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_TRACE_ALLOCATOR_VOLUME "$BACKUP_DIR/$BACKUP_TRACE_ALLOCATOR_VOLUME"  #TODO ONLY COMPACTED DATA
BACKUP_STORAGE_VOLUME="simva_storage_data"
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_STORAGE_VOLUME "$BACKUP_DIR/$BACKUP_STORAGE_VOLUME"
BACKUP_TRACE_ALLOCATOR_LOGS_VOLUME="simva_trace_allocator_logs"
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_TRACE_ALLOCATOR_LOGS_VOLUME "$BACKUP_DIR/$BACKUP_TRACE_ALLOCATOR_LOGS_VOLUME"
BACKUP_BACKEND_LOGS_CONFIG_VOLUME="simva_api_logs"
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_BACKEND_LOGS_CONFIG_VOLUME "$BACKUP_DIR/$BACKUP_BACKEND_LOGS_CONFIG_VOLUME"
BACKUP_FRONT_LOGS_VOLUME="simva_front_logs"
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_FRONT_LOGS_VOLUME "$BACKUP_DIR/$BACKUP_FRONT_LOGS_VOLUME"
echo "✅ Backup completed!"