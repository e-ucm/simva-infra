#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

BACKUP_DIR="${SIMVA_BACKUP_HOME}/shlink"

# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="shlink"
_stop_docker_container_if_running

echo "💾 Creating new backup..."
BACKUP_VOLUME="shlink_db"
"${SIMVA_BIN_HOME}/volumectl.sh" backup $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME"
BACKUP_CONFIG_VOLUME="shlink_config"
"${SIMVA_BIN_HOME}/volumectl.sh" backup $BACKUP_CONFIG_VOLUME "$BACKUP_DIR/$BACKUP_CONFIG_VOLUME"
echo "✅ Backup completed!"