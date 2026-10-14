#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/migrate-to-volume.sh"

if [[ ! -f "$SIMVA_DATA_HOME/simva/sqlite_init" ]]; then
    echo "SQLite initialization file not found. Starting migration if needed."
    if [[ -f "$SIMVA_DATA_HOME/simva/migration_sqlite_in_progress" ]]; then
        echo "Migration in progress. Skipping SQLite initialization."
        exit 0
    elif [[ ! -f "$SIMVA_DATA_HOME/simva/.initialized" ]]; then
        # Fresh installation: there is no MongoDB database to migrate, the simva stack initializes
        # SQLite directly, so skip the MongoDB to SQLite migration.
        echo "Fresh installation detected, no MongoDB database to migrate."
        touch "$SIMVA_DATA_HOME/simva/sqlite_init"
        echo "Created SQLite initialization file."
    else
        echo "Starting migration from MongoDB to SQLite."
        "${SIMVA_HOME}/simva" migrate_db "${SIMVA_SCRIPT_WAIT_TIME:-10}" "${CURRENT_STACK}"
        "${HELPERS_STACK_HOME}/migrate-to-volume.sh"
    fi
else 
    echo "SQLite initialization file detected. Skipping SQLite initialization."
    exit 0
fi