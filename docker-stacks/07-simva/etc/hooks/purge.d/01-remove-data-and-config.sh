#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/simva/simva-api" \
    "${SIMVA_DATA_HOME}/simva/simva-front" \
    "${SIMVA_DATA_HOME}/simva/simva-trace-allocator"

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/simva/.initialized" \
    "${SIMVA_DATA_HOME}/simva/.externaldomain" \
    "${SIMVA_DATA_HOME}/simva/.version" \
    "${SIMVA_DATA_HOME}/simva/simva-api-sha256sums" \
    "${SIMVA_DATA_HOME}/simva/simva-front-sha256sums" \
    "${SIMVA_DATA_HOME}/simva/simva-trace-allocator-sha256sums"

"${SIMVA_BIN_HOME}/volumectl.sh" delete "simva_trace_allocator_data"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "simva_trace_allocator_logs"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "simva_front_logs"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "simva_api_logs"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "simva_storage_data"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "simva_mongodb_data"