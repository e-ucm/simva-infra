#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/wait-available.sh "Limesurvey" "https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN:-limesurvey}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/" "true" "false";