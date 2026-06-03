#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${SIMVA_BIN_HOME}/volumectl.sh" delete "pumva_logs"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "pumva_sqlite_data"

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "$SIMVA_DATA_HOME/pumva/sqlite_init" \
    "$SIMVA_DATA_HOME/pumva/sqlite_initialisation_in_progress" \
    "$SIMVA_DATA_HOME/pumva/.initialized" \
    "$SIMVA_DATA_HOME/pumva/.externaldomain" \
    "$SIMVA_DATA_HOME/pumva/.version"