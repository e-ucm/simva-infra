#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source "${SIMVA_BIN_HOME}/extension-helper.sh"

# Local deployment builds the extensions from sources next to simva-infra: fetch them if missing.
if [[ "${SIMVA_KEYCLOAK_EXTENSION_LOCAL_DEPLOYMENT:-false}" == "true" ]]; then
    checkout_local_repo "${SIMVA_KEYCLOAK_EXTENSIONS_LOCAL_PATH}" "keycloak-extensions" "v${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}"
fi
