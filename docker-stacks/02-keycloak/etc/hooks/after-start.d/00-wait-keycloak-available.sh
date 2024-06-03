#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/wait-available.sh "Keycloak" "https://${SIMVA_SSO_HOST_SUBDOMAIN:-sso}.${SIMVA_EXTERNAL_DOMAIN:-external.test}" "true" "false"