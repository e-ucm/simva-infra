#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

if [[ ! -f "$SIMVA_DATA_HOME/pumva/sqlite_init" ]]; then
    if [[ -f "$SIMVA_DATA_HOME/pumva/sqlite_initialisation_in_progress" ]]; then
        echo "Migration in progress. Skipping SQLite initialization."
        exit 0
    else
        "${SIMVA_HOME}/simva" migrate_db ${CURRENT_STACK}
    fi
fi