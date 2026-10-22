#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# BACKUP_DIR is set by the main restore function based on SIMVA_RESTORE_TIMESTAMP
# Use it directly instead of determining it here

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="shlink"
_stop_docker_container_if_running

BACKUP_VOLUME="shlink_db"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_VOLUME"
"${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_VOLUME "$BACKUP_DIR/$BACKUP_VOLUME"
BACKUP_CONFIG_VOLUME="shlink_config"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_CONFIG_VOLUME"
"${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_CONFIG_VOLUME "$BACKUP_DIR/$BACKUP_CONFIG_VOLUME"
echo "✅ Restore completed successfully."