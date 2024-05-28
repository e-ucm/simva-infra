#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/network/.initialized" \
    "${SIMVA_DATA_HOME}/network/.externaldomain" \
    "${SIMVA_DATA_HOME}/network/.version"