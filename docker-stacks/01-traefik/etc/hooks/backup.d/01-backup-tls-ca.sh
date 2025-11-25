#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source "${SIMVA_BIN_HOME}/backup-restore.sh"
BACKUP_TLS_DIR="${SIMVA_BACKUP_HOME}/${STACK_NAME}/tls"
backup $SIMVA_TLS_HOME $BACKUP_TLS_DIR true
echo "✅ Backup completed: $BACKUP_TLS_DIR"

BACKUP_ENV_DIR="${SIMVA_BACKUP_HOME}/${STACK_NAME}/simva-env"
backup "$SIMVA_ETC_HOME/simva.d" $BACKUP_ENV_DIR true
echo "✅ Backup completed: $BACKUP_ENV_DIR"