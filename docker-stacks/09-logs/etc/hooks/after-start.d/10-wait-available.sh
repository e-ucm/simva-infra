#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then
  ${SIMVA_HOME}/bin/wait-available.sh "Portainer" "https://${SIMVA_PORTAINER_HOST_SUBDOMAIN:-portainer}.${SIMVA_EXTERNAL_DOMAIN:-external.test}" "true" "false";
fi;