#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

BACKUP_DIR="${SIMVA_BACKUP_HOME}/simva"
BACKUP_SQL_FILE=${SIMVA_API_MYSQL_DB:-simva}.mysql.sql
BACKUP_SQLITE_FILE=${SIMVA_API_MYSQL_DB:-simva}.sqlite
MIGRATION_DIR_NAME="sqllite"
# Check if the container is running
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="mysql"
_start_docker_container_if_not_running

docker compose exec mysql bash -c "
  if [[ ! -d /var/lib/mysql/backup_sqlite ]]; then
       mkdir /var/lib/mysql/backup_sqlite;
  fi
"

 "${SIMVA_BIN_HOME}/run-command.sh" bash -c "
       mysqldump \
        -u ${SIMVA_MYSQL_USER:-dbuser} -p${SIMVA_MYSQL_PASSWORD:-userpass} \
        --no-tablespaces \
        --compatible=ansi \
        --skip-add-locks \
        --skip-comments \
        --skip-set-charset \
         ${SIMVA_API_MYSQL_DB:-simva} > /var/lib/mysql/backup_sqlite/${BACKUP_SQL_FILE};
       ls -lia /var/lib/mysql/backup_sqlite/;"

#docker compose exec mysql bash -c "
#  grep -E 'CREATE TABLE|INSERT INTO' \
#  /var/lib/mysql/backup_sqlite/${BACKUP_SQL_FILE} | head
#"
"${SIMVA_BIN_HOME}/run-command.sh" sh -c "
  cat /var/lib/mysql/backup_sqlite/${BACKUP_SQL_FILE} | head
"

export RUN_IN_CONTAINER_NAME="mysql2sqlite"
_start_docker_container_if_not_running
"${SIMVA_BIN_HOME}/run-command.sh" sh -c "mysql2sqlite /data/backup_sqlite/${BACKUP_SQL_FILE} | tee /tmp/out.sql | sqlite3 /data/backup_sqlite/${BACKUP_SQLITE_FILE} && ls -lh /tmp/out.sql"

"${SIMVA_BIN_HOME}/run-command.sh" sh -c "
  cat /data/backup_sqlite/${BACKUP_SQLITE_FILE} | head
"

if [[ ! -d $BACKUP_DIR/$MIGRATION_DIR_NAME ]]; then 
       mkdir $BACKUP_DIR/$MIGRATION_DIR_NAME
fi
if [[ ! -d "$SIMVA_DATA_HOME/simva/sqlite" ]]; then 
       mkdir "$SIMVA_DATA_HOME/simva/sqlite"
fi

"${SIMVA_BIN_HOME}/volumectl.sh" copyvl "simva_mysql_data" $BACKUP_DIR/$MIGRATION_DIR_NAME backup/$BACKUP_SQLITE_FILE $BACKUP_SQLITE_FILE true
"${SIMVA_BIN_HOME}/volumectl.sh" copyvl "simva_mysql_data" $SIMVA_DATA_HOME/simva/sqlite backup/$BACKUP_SQLITE_FILE $BACKUP_SQLITE_FILE false
"${SIMVA_BIN_HOME}/run-command.sh" sh -c "rm -rf '/data/backup_sqlite'"
ls -lia $BACKUP_DIR/$MIGRATION_DIR_NAME