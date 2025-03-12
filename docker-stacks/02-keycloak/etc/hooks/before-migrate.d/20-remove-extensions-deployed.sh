#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/keycloak/deployments"