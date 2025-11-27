#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_BACKUP_HOME}/limesurvey"

# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="limesurvey"
_stop_docker_container_if_running

BACKUP_UPLOAD="ls_upload"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_UPLOAD"
"${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_UPLOAD "$BACKUP_DIR/$BACKUP_UPLOAD"
BACKUP_TMP="ls_tmp"
echo "🕐 Restoring from backup: $BACKUP_DIR/$BACKUP_TMP"
"${SIMVA_BIN_HOME}/volumectl.sh" restore $BACKUP_TMP "$BACKUP_DIR/$BACKUP_TMP"
echo "✅ Restore completed successfully."