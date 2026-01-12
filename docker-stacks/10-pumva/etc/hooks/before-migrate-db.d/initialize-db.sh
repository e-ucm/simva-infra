#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -xç

if [[ -f "$SIMVA_DATA_HOME/pumva/sqlite_init" ]]; then
    echo "SQLite initialization file detected. Skipping SQLite initilisation."
    exit 0
fi

touch "$SIMVA_DATA_HOME/pumva/sqlite_initialisation_in_progress"