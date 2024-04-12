#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x
keycloakVersionFile="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/keycloakversion.txt"
if [[ ! -e "${SIMVA_PROJECT_DIR}/.simva-initialized" ]]; then 
    $SIMVA_KEYCLOAK_VERSION > $keycloakVersionFile
    docker exec -it 02-keycloak-keycloak-1 /opt/keycloak/bin/kc.sh import --file "/opt/keycloak/data/import/simva-realm-full.json" --override true --optimized
else
    if [[ -e "${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export/${SIMVA_SSO_REALM:-simva}-realm-full.json" ]]; then
        previousVersion=0
        if [[ -e "${keycloakVersionFile}" ]]; then 
            previousVersion=$(cat $keycloakVersionFile)    
        fi;
        if [[ ! $SIMVA_KEYCLOAK_VERSION == $previousVersion ]]; then
            docker exec -it 02-keycloak-keycloak-1 /opt/keycloak/bin/kc.sh import --file "/opt/keycloak/data/export/${SIMVA_SSO_REALM:-simva}-realm-full.json" --override true --optimized
            echo $SIMVA_KEYCLOAK_VERSION > $keycloakVersionFile
        fi;
    fi;
fi;