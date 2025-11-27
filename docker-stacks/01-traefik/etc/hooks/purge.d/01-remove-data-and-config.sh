#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-folder-contents.sh \
    "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf" \
    "${SIMVA_TLS_HOME}" \
    "${SIMVA_DATA_HOME}/traefik/csp-reporter"

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/traefik/.initialized" \
    "${SIMVA_DATA_HOME}/traefik/.externaldomain" \
    "${SIMVA_DATA_HOME}/traefik/.version"

rm -rf "${SIMVA_TLS_HOME}/ca"