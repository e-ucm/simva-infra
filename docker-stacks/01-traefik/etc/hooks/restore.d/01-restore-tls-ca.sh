#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source "${SIMVA_BIN_HOME}/backup-restore.sh"
restore_data $BACKUP_DIR/tls $SIMVA_TLS_HOME true
echo "✅ Backup $BACKUP_TLS_DIR restored!"
restore_data $BACKUP_DIR/simva-env "$SIMVA_ETC_HOME/simva.d" true
echo "✅ Backup $BACKUP_ENV_DIR restored!"