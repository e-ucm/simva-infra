#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/keycloak/deployments"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/keycloak/extensions/SHA256SUMS-KEYCLOAK-EXTENSIONS-${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}"