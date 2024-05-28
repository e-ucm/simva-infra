#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

SIMVA_DOZZLE_PASSWORD_HASHED=$(echo -n $SIMVA_DOZZLE_PASSWORD | sha256sum | awk '{print $1}')
config_contents=$(<"${SIMVA_CONFIG_HOME}/logs/dozzle-config-template/users.yml")
echo "${config_contents}" \
    | sed  "s/<<SIMVA_DOZZLE_USERNAME>>/${SIMVA_DOZZLE_USERNAME}/g" \
    | sed  "s/<<SIMVA_DOZZLE_PASSWORD>>/${SIMVA_DOZZLE_PASSWORD_HASHED}/g" \
    > "${SIMVA_CONFIG_HOME}/logs/dozzle-config/users.yml"

echo -n "${SIMVA_PORTAINER_ADMIN_PASSWORD}" > "${SIMVA_CONFIG_HOME}/logs/portainer-config/portainer_password"