#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-folder-contents.sh \
    "${SIMVA_CONFIG_HOME}/keycloak/simva-realm"

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_CONFIG_HOME}/keycloak/realm-data.dev.yml" \
    "${SIMVA_CONFIG_HOME}/keycloak/realm-data.prod.yml"

touch "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.exportinprogress"
touch "${SIMVA_CONFIG_HOME}/keycloak/.migration"