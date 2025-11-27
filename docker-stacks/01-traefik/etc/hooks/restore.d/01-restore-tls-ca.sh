#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source "${SIMVA_BIN_HOME}/backup-restore.sh"
BACKUP_TLS_DIR="${SIMVA_BACKUP_HOME}/${STACK_NAME}/tls"
restore_data $BACKUP_TLS_DIR $SIMVA_TLS_HOME true
echo "✅ Backup $BACKUP_TLS_DIR restored!"

BACKUP_ENV_DIR="${SIMVA_BACKUP_HOME}/${STACK_NAME}/simva-env"
restore_data $BACKUP_ENV_DIR "$SIMVA_ETC_HOME/simva.d" true
echo "✅ Backup $BACKUP_ENV_DIR restored!"