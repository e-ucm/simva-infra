#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_BACKUP_HOME}/simva"
SQLITE_DIR_NAME="sqllite"
BACKUP_SQLITE_FILE=${SIMVA_API_MYSQL_DB:-simva}_data.db

# Check if the container is running
#source "${SIMVA_BIN_HOME}/check-docker-running.sh"
#export RUN_IN_CONTAINER=true
#export RUN_IN_CONTAINER_NAME="simva-api"
#_stop_docker_container_if_running

if [[ ! -d $BACKUP_DIR/$SQLITE_DIR_NAME ]]; then 
       mkdir $BACKUP_DIR/$SQLITE_DIR_NAME
fi

"${SIMVA_BIN_HOME}/volumectl.sh" copyvl "simva_sqlite_data" $BACKUP_DIR/$SQLITE_DIR_NAME $BACKUP_SQLITE_FILE $BACKUP_SQLITE_FILE true
ls -lia $BACKUP_DIR/$SQLITE_DIR_NAME