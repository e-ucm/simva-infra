#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/wait-available.sh "TMon" "https://${SIMVA_TMON_DASHBOARD_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" "false" "false";

if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
  ${SIMVA_HOME}/bin/wait-available.sh "Jupyter" "https://${SIMVA_JUPYTER_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" "false" "false";
fi;