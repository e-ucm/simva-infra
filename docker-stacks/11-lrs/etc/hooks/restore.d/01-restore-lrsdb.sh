#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

BACKUP_DIR="${SIMVA_BACKUP_HOME}/${STACK_NAME}"
MIGRATION_DIR_NAME="db"
BACKUP_FILE="lrs.sql"
BACKUP_FILE_COMPRESSED="$BACKUP_FILE.tar.gz"

DB_USER="${SIMVA_LRS_DB_USER:-lrs}"
DB_NAME="${SIMVA_LRS_DB_NAME:-lrs}"

# If a previous backup exists
previousBackupPath="$BACKUP_DIR/$MIGRATION_DIR_NAME/$BACKUP_FILE_COMPRESSED"
if [[ ! -f "$previousBackupPath" ]]; then
    echo "❌ No backup file found in $BACKUP_DIR/$MIGRATION_DIR_NAME"
    exit 1
fi

echo "🕐 Restoring database from backup: $previousBackupPath"
export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="postgres"
# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"

"${SIMVA_HOME}/simva" start 00-network
export RUN_IN_CONTAINER_NAME="db"
_start_docker_container_if_not_running
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "until pg_isready -q -U '$DB_USER' -d '$DB_NAME'; do sleep 2; done"

_copy_to_docker_container "$previousBackupPath" "/tmp/$BACKUP_FILE_COMPRESSED"
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "rm -rf '/tmp/$MIGRATION_DIR_NAME' && mkdir -p '/tmp/$MIGRATION_DIR_NAME' && tar -xzf '/tmp/$BACKUP_FILE_COMPRESSED' -C '/tmp/$MIGRATION_DIR_NAME'"
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "psql -U '$DB_USER' -d '$DB_NAME' -v ON_ERROR_STOP=1 -f '/tmp/$MIGRATION_DIR_NAME/$BACKUP_FILE'"
# The archive is copied in as root, it cannot be removed by the postgres user
RUN_IN_AS_SPECIFIC_USER="root" "${SIMVA_BIN_HOME}/run-command.sh" bash -c "rm -rf '/tmp/$MIGRATION_DIR_NAME' '/tmp/$BACKUP_FILE_COMPRESSED'"
echo "✅ Restore completed successfully."