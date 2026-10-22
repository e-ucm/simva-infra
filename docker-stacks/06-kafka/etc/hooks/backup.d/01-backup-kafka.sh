#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

BACKUP_DIR="${SIMVA_BACKUP_HOME}/kafka"
BACKUP_VOLUME="kafka_data"

# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="kafka"
_stop_docker_container_if_running

echo "💾 Creating new backup..."
"${SIMVA_BIN_HOME}/volumectl.sh" backup $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME" $(cat "${SIMVA_BACKUP_HOME}/${STACK_NAME}/.timestamp")
echo "✅ Backup completed!"