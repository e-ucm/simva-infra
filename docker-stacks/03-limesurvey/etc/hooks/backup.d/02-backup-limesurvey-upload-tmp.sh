#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_BACKUP_HOME}/limesurvey"

# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="limesurvey"
_stop_docker_container_if_running

echo "💾 Creating new backup..."
BACKUP_UPLOAD="ls_upload"
"${SIMVA_BIN_HOME}/volumectl.sh" backup $BACKUP_UPLOAD "$BACKUP_DIR/$BACKUP_UPLOAD" $(cat "${SIMVA_BACKUP_HOME}/limesurvey/.timestamp")
BACKUP_TMP="ls_tmp"
"${SIMVA_BIN_HOME}/volumectl.sh" backup $BACKUP_TMP "$BACKUP_DIR/$BACKUP_TMP" $(cat "${SIMVA_BACKUP_HOME}/limesurvey/.timestamp")
echo "✅ Backup completed!"