#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -f "$SIMVA_DATA_HOME/simva/sqlite_init" ]]; then
    echo "SQLite initialization file detected. Skipping MongoDB to SQLite migration."
    exit 0
fi

touch "$SIMVA_DATA_HOME/simva/migration_sqlite_in_progress"