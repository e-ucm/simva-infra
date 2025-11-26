#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_BACKUP_HOME}/limesurvey/db"
BACKUP_FILE="limesurvey.sql"
BACKUP_FILE_COMPRESSED="$BACKUP_FILE.tar.gz"

# If a previous backup exists
previousBackupPath="$BACKUP_DIR/$BACKUP_FILE_COMPRESSED"
if [[ ! -f "$previousBackupPath" ]]; then
    echo "❌ No backup file found in $BACKUP_DIR"
  exit 1
fi

echo "🕐 Restoring database from backup: $previousBackupPath"
# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="root"

export RUN_IN_CONTAINER_NAME="limesurvey"
_stop_docker_container_if_running

export RUN_IN_CONTAINER_NAME="mariadb-backup"
_stop_docker_container_if_running
"${SIMVA_BIN_HOME}/volumectl.sh" copylv $BACKUP_DIR "ls_maria_db_backup_data" $BACKUP_FILE_COMPRESSED "restore" true
"${SIMVA_BIN_HOME}/volumectl.sh" exec "ls_maria_db_backup_data" "/dump" "ls -lia /dump/restore"

export RUN_IN_CONTAINER_NAME="mariadb"
_start_docker_container_if_not_running
export RUN_IN_CONTAINER_NAME="mariadb-backup"
_start_docker_container
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "/container-tools/wait-for-it.sh -h mariadb.${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN} -p 3306 -t ${SIMVA_WAIT_TIMEOUT}"
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "mysql -h'mariadb.${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}' -uroot -p'${SIMVA_LIMESURVEY_MYSQL_ROOT_PASSWORD}' < '/dump/restore/$BACKUP_FILE'"
"${SIMVA_BIN_HOME}/run-command.sh" bash -c "rm -rf '/dump/restore'"
echo "✅ Restore completed successfully."