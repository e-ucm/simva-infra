#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_HOME}/backup/limesurvey/db"
BACKUP_FILE="limesurvey.sql"

# If a previous backup exists
previousBackupPath="$BACKUP_DIR/$BACKUP_FILE.tar.gz"
if [[ -f "$previousBackupPath" ]]; then
    last_backup_timestamp=$(cat "${SIMVA_BACKUP_HOME}/limesurvey/.timestamp")
    echo "📦 Previous backup detected at $previousBackupPath"

    # Create timestamped subfolder
    OLD_DIR="$BACKUP_DIR/old_${last_backup_timestamp}"
    mkdir -p "$OLD_DIR"

    # Move old backup
    mv "$previousBackupPath" "$OLD_DIR/"
    echo "🕐 Moved old backup to $OLD_DIR/"
fi

echo "💾 Creating new backup..."
export RUN_IN_CONTAINER=true

export RUN_IN_AS_SPECIFIC_USER="root"
# Check if the container is running
source "${SIMVA_HOME}/bin/check-docker-running.sh"
export RUN_IN_CONTAINER_NAME="mariadb"
_start_docker_container_if_not_running
export RUN_IN_CONTAINER_NAME="mariadb-backup"
_start_docker_container_if_not_running
"${SIMVA_HOME}/bin/run-command.sh" bash -c "/container-tools/wait-for-it.sh -h mariadb.${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN} -p 3306 -t ${SIMVA_WAIT_TIMEOUT}"
"${SIMVA_HOME}/bin/run-command.sh" bash -c "mysqldump --all-databases -h'mariadb.${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}' -uroot -p'${SIMVA_LIMESURVEY_MYSQL_ROOT_PASSWORD}' > '/dump/$BACKUP_FILE'"
"${SIMVA_HOME}/bin/volumectl.sh" copyvl "ls_maria_db_backup_data" $BACKUP_DIR $BACKUP_FILE $BACKUP_FILE true
"${SIMVA_HOME}/bin/run-command.sh" bash -c "rm -rf '/dump/$BACKUP_FILE'"
echo "✅ Backup completed: $BACKUP_FILE"