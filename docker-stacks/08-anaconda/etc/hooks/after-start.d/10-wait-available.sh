#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then
  ${SIMVA_HOME}/bin/wait-available.sh "Jupyter" "https://${SIMVA_JUPYTER_HOST_SUBDOMAIN:-jupyter}.${SIMVA_EXTERNAL_DOMAIN:-external.test}" "false" "false";
fi;