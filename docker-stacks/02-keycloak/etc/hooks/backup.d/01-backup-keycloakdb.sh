#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_BACKUP_HOME}/${STACK_NAME}"
MIGRATION_DIR_NAME="db"
BACKUP_FILE="keycloak.sql"

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

# If a previous backup exists
previousBackupPath="$BACKUP_DIR/$MIGRATION_DIR_NAME/$BACKUP_FILE.tar.gz"
if [[ -f "$previousBackupPath" ]]; then
    last_backup_timestamp=$(cat "${SIMVA_BACKUP_HOME}/keycloak/.timestamp")
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
export RUN_IN_AS_SPECIFIC_USER="root"
# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"

"${SIMVA_HOME}/simva" start 00-network
export RUN_IN_CONTAINER_NAME="keycloak"
_stop_docker_container_if_running
export RUN_IN_CONTAINER_NAME="mariadb"
_start_docker_container_if_not_running
export RUN_IN_CONTAINER_NAME="mariadb-backup"
_start_docker_container_if_not_running
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "/container-tools/wait-for-it.sh -h mariadb.${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN} -p 3306 -t ${SIMVA_WAIT_TIMEOUT}"
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "mysqldump --all-databases -h'mariadb.${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}' -uroot -p'${SIMVA_KEYCLOAK_MYSQL_ROOT_PASSWORD}' > '/dump/$BACKUP_FILE'"
"${SIMVA_BIN_HOME}/volumectl.sh" copyvl "kc_maria_db_backup_data" $BACKUP_DIR/$MIGRATION_DIR_NAME $BACKUP_FILE $BACKUP_FILE true
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "rm -rf '/dump/$BACKUP_FILE'"
echo "✅ Backup completed: $BACKUP_FILE"