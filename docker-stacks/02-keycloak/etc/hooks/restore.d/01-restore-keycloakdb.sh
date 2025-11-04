#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_HOME}/backup/keycloak/db"
BACKUP_FILE="keycloak.sql"
BACKUP_FILE_COMPRESSED="$BACKUP_FILE.tar.gz"

# If a previous backup exists
previousBackupPath="$BACKUP_DIR/$BACKUP_FILE_COMPRESSED"
if [[ ! -f "$previousBackupPath" ]]; then
    echo "❌ No backup file found in $BACKUP_DIR"
    exit 1
fi

echo "🕐 Restoring database from backup: $previousBackupPath"
# Check if the container is running
source "${SIMVA_HOME}/bin/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="root"

export RUN_IN_CONTAINER_NAME="keycloak"
_stop_docker_container_if_running

export RUN_IN_CONTAINER_NAME="mariadb-backup"
_stop_docker_container_if_running
"${SIMVA_HOME}/bin/volumectl.sh" exec "kc_maria_db_backup_data" "/dump" "ls -lia /dump"
"${SIMVA_HOME}/bin/volumectl.sh" copylv $BACKUP_DIR "kc_maria_db_backup_data" $BACKUP_FILE_COMPRESSED "restore" true
"${SIMVA_HOME}/bin/volumectl.sh" exec "kc_maria_db_backup_data" "/dump" "ls -lia /dump && ls -lia /dump/restore"

export RUN_IN_CONTAINER_NAME="mariadb"
_start_docker_container_if_not_running
export RUN_IN_CONTAINER_NAME="mariadb-backup"
_start_docker_container
"${SIMVA_HOME}/bin/run-command.sh" bash -c "/container-tools/wait-for-it.sh -h mariadb.${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN} -p 3306 -t ${SIMVA_WAIT_TIMEOUT}"
"${SIMVA_HOME}/bin/run-command.sh" bash -c "mysql -h'mariadb.${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}' -uroot -p'${SIMVA_KEYCLOAK_MYSQL_ROOT_PASSWORD}' < '/dump/restore/$BACKUP_FILE'"
"${SIMVA_HOME}/bin/run-command.sh" bash -c "rm -rf '/dump/restore'"
echo "✅ Restore completed successfully."