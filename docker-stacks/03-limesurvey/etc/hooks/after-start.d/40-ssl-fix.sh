#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Variable
export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="root"
export RUN_IN_CONTAINER_NAME="limesurvey"

"${SIMVA_BIN_HOME}/run-command.sh" bash -c 'echo "if[[ ! -e /etc/ssl/certs/rootCA-simva.pem ]]; then cp /root/.limesurvey/certs/ca/rootCA.pem /etc/ssl/certs/rootCA-simva.pem fi;"'

if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/.initializedSSL" ]]; then 
    # Step 1: Update cainfo in php.ini
    "${SIMVA_BIN_HOME}/run-command.sh" bash -c 'echo "curl.cainfo=/etc/ssl/certs/rootCA-simva.pem" >> "/usr/local/etc/php/php.ini"'
    
    # Step 2: Optional - Restart the Docker container if necessary
    docker compose restart $RUN_IN_CONTAINER_NAME
    ${SIMVA_BIN_HOME}/wait-available.sh "Limesurvey" "https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/admin/authentication/sa/login" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";

    touch "${SIMVA_DATA_HOME}/limesurvey/.initializedSSL"
fi