#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/simva/mongo" \
    "${SIMVA_DATA_HOME}/simva/puppeteer/" \
    "${SIMVA_DATA_HOME}/simva/simva-api/" \
    "${SIMVA_DATA_HOME}/simva/simva-front/" \
    "${SIMVA_DATA_HOME}/simva/simva-trace-allocator/"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/simva/.initialized" \
    "${SIMVA_DATA_HOME}/simva/.externaldomain" \
    "${SIMVA_DATA_HOME}/simva/.version"