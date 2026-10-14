#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -f "$SIMVA_DATA_HOME/pumva/sqlite_initialisation_in_progress" ]]; then
    set +e
    docker compose wait "pumva-database-initialization"
    set -e
    rm -f "$SIMVA_DATA_HOME/pumva/sqlite_initialisation_in_progress"
    touch "$SIMVA_DATA_HOME/pumva/sqlite_init"
    echo "Created SQLite initialization file."
    echo "Database initialization finished. Continuing startup."
else 
    echo "Initialization not in progress. Continuing normal operations."
    exit 0
fi