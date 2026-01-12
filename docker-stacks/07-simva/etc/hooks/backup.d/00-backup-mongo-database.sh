#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"
BACKUP_DIR="${SIMVA_BACKUP_HOME}/simva"

# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="simva-trace-allocator"
_stop_docker_container_if_running
export RUN_IN_CONTAINER_NAME="simva-front"
_stop_docker_container_if_running
export RUN_IN_CONTAINER_NAME="simva-api"
_stop_docker_container_if_running

if [[ ! -f "$SIMVA_DATA_HOME/simva/sqlite_init" ]]; then
    MIGRATION_DIR_NAME="simva_mongodb_data"
    BACKUP_FILE="export"
else 
    MIGRATION_DIR_NAME="sqllite"
    BACKUP_FILE=${SIMVA_API_MYSQL_DB:-simva}_data.db
fi 

# If a previous backup exists
previousBackupPath="$BACKUP_DIR/$MIGRATION_DIR_NAME/$BACKUP_FILE.tar.gz"
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

if [[ ! -f "$SIMVA_DATA_HOME/simva/sqlite_init" ]]; then
    export RUN_IN_CONTAINER_NAME="mongodb"
    _start_docker_container_if_not_running
    "${SIMVA_BIN_HOME}/run-command.sh" bash -c "
    echo 'Waiting for MongoDB...'
    sleep 5
    echo 'Exporting all collections...'

    collections=\$(mongo --quiet \"mongodb://${SIMVA_MONGO_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}:27017${SIMVA_API_MONGO_DB}\" --eval 'db.getCollectionNames().join(\" \")')

    for collection in \$collections; do
    echo \"Exporting \$collection...\"
    mongoexport \
        --uri=\"mongodb://${SIMVA_MONGO_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}:27017${SIMVA_API_MONGO_DB}\" \
        --collection=\"\$collection\" \
        --out=\"/data/db/export/\$collection.json\"
    done

    echo 'Export finished!'
    ls -lia /data/db/export
    "
    backup_Folder="$BACKUP_DIR/$MIGRATION_DIR_NAME/$BACKUP_FILE"
    if [[ -d "$backup_Folder" ]]; then
        rm -rf $backup_Folder
    fi

    "${SIMVA_BIN_HOME}/volumectl.sh" copyvl "simva_mongodb_data" $BACKUP_DIR/$MIGRATION_DIR_NAME $BACKUP_FILE $BACKUP_FILE false
    "${SIMVA_BIN_HOME}/volumectl.sh" copyvl "simva_mongodb_data" $BACKUP_DIR/$MIGRATION_DIR_NAME $BACKUP_FILE $BACKUP_FILE true
else 
    if [[ ! -d $BACKUP_DIR/$SQLITE_DIR_NAME ]]; then 
        mkdir $BACKUP_DIR/$SQLITE_DIR_NAME
    fi

    set +e
    "${SIMVA_BIN_HOME}/volumectl.sh" copyvl "simva_sqlite_data" $BACKUP_DIR/$MIGRATION_DIR_NAME $BACKUP_FILE $BACKUP_FILE true
    set -e
    ls -lia $BACKUP_DIR/$MIGRATION_DIR_NAME
fi