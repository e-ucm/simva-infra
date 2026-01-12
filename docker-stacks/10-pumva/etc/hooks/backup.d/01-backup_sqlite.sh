#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_BACKUP_HOME}/pumva"
SQLITE_DIR_NAME="sqllite"
BACKUP_SQLITE_FILE=${SIMVA_PUMVA_SQLITE_DB_FILE:-pumva_data.db}
if [[ ! -d $BACKUP_DIR/$SQLITE_DIR_NAME ]]; then 
    mkdir $BACKUP_DIR/$SQLITE_DIR_NAME
fi
set +e
"${SIMVA_BIN_HOME}/volumectl.sh" copyvl "pumva_sqlite_data" $BACKUP_DIR/$SQLITE_DIR_NAME $BACKUP_SQLITE_FILE $BACKUP_SQLITE_FILE true
set -e
ls -lia $BACKUP_DIR/$SQLITE_DIR_NAME