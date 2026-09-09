#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -f "$SIMVA_DATA_HOME/simva/migration_sqlite_in_progress" ]]; then
    set +e
    docker compose wait "mongodb_migration"
    set -e
    rm -f "$SIMVA_DATA_HOME/simva/migration_sqlite_in_progress"
    touch "$SIMVA_DATA_HOME/simva/sqlite_init"
    echo "Created SQLite initialization file."
    echo "Database migration finished. Continuing startup."
else 
    echo "Migration not in progress. Continuing normal operations."
    exit 0
fi