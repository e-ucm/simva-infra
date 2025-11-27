#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-folder-contents.sh \
    "${SIMVA_CONFIG_HOME}/minio/policies"

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/minio/.minio-initialized" \
    "${SIMVA_DATA_HOME}/minio/.minio-events-initialized" \
    "${SIMVA_DATA_HOME}/minio/.initialized" \
    "${SIMVA_DATA_HOME}/minio/.externaldomain" \
    "${SIMVA_DATA_HOME}/minio/.version"

"${SIMVA_BIN_HOME}/volumectl.sh" delete "minio_data"