#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

BACKUP_DIR="${SIMVA_BACKUP_HOME}/${STACK_NAME}"
MIGRATION_DIR_NAME="db"
BACKUP_FILE="lrs.sql"
BACKUP_FILE_COMPRESSED="$BACKUP_FILE.tar.gz"
CONTAINER_DUMP="/tmp/$BACKUP_FILE"

DB_USER="${SIMVA_LRS_DB_USER:-lrs}"
DB_NAME="${SIMVA_LRS_DB_NAME:-lrs}"

# If a previous backup exists
previousBackupPath="$BACKUP_DIR/$MIGRATION_DIR_NAME/$BACKUP_FILE_COMPRESSED"
if [[ -f "$previousBackupPath" ]]; then
    last_backup_timestamp=$(cat "${SIMVA_BACKUP_HOME}/${STACK_NAME}/.timestamp")
    echo "📦 Previous backup detected at $previousBackupPath"

    # Create timestamped subfolder
    OLD_DIR="$BACKUP_DIR/old/${last_backup_timestamp}/${MIGRATION_DIR_NAME}"
    if [[ ! -d "$OLD_DIR" ]]; then
        mkdir -p "$OLD_DIR"
    fi

    # Move old backup
    mv "$previousBackupPath" "$OLD_DIR/"
    echo "🕐 Moved old backup to $OLD_DIR/"
fi

echo "💾 Creating new backup..."
export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="postgres"
# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"

"${SIMVA_HOME}/simva" start 00-network
export RUN_IN_CONTAINER_NAME="db"
_start_docker_container_if_not_running
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "until pg_isready -q -U '$DB_USER' -d '$DB_NAME'; do sleep 2; done"

mkdir -p "$BACKUP_DIR/$MIGRATION_DIR_NAME"
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "pg_dump -U '$DB_USER' -d '$DB_NAME' --clean --if-exists --no-owner > '$CONTAINER_DUMP'"
_copy_from_docker_container "$CONTAINER_DUMP" "$BACKUP_DIR/$MIGRATION_DIR_NAME/$BACKUP_FILE"
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "rm -f '$CONTAINER_DUMP'"
tar -czf "$previousBackupPath" -C "$BACKUP_DIR/$MIGRATION_DIR_NAME" "$BACKUP_FILE"
rm -f "$BACKUP_DIR/$MIGRATION_DIR_NAME/$BACKUP_FILE"
echo "✅ Backup completed: $previousBackupPath"