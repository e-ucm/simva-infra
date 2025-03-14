#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_CONFIG_HOME}/keycloak/simva-realm"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_CONFIG_HOME}/keycloak/realm-data.dev.yml" \
    "${SIMVA_CONFIG_HOME}/keycloak/realm-data.prod.yml"

touch "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.exportinprogress"