#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source "${SIMVA_BIN_HOME}/backup-restore.sh"
BACKUP_TLS_DIR="${SIMVA_BACKUP_HOME}/${STACK_NAME}/tls"
backup_data $SIMVA_TLS_HOME $BACKUP_TLS_DIR $(cat "${SIMVA_BACKUP_HOME}/${STACK_NAME}/.timestamp") true
echo "✅ Backup completed: $BACKUP_TLS_DIR"
