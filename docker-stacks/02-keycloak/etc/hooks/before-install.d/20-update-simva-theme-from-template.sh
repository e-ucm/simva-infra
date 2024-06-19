#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

simvaURL="${SIMVA_EXTERNAL_PROTOCOL}://${SIMVA_EXTERNAL_DOMAIN}/"
cat "${SIMVA_CONFIG_HOME}/keycloak/themes/simva/account/theme.properties.template" \
     | sed  "s|logoUrl=<<SIMVA_SIMVA_URL>>|logoUrl=${simvaURL}|" \
> "${SIMVA_CONFIG_HOME}/keycloak/themes/simva/account/theme.properties"