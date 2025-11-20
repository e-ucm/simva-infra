#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_HOME}/backup/shlink"

# Check if the container is running
source "${SIMVA_HOME}/bin/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="shlink"
_stop_docker_container_if_running

echo "💾 Creating new backup..."
BACKUP_VOLUME="shlink_db"
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME"
BACKUP_CONFIG_VOLUME="shlink_config"
"${SIMVA_HOME}/bin/volumectl.sh" backup $BACKUP_CONFIG_VOLUME "$BACKUP_DIR/$BACKUP_CONFIG_VOLUME"
echo "✅ Backup completed!"