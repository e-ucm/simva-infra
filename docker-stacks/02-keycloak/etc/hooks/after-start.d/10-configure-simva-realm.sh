#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
    if [[ ! -e "${SIMVA_DATA_HOME}/keycloak/.initialized" ]]; then 
        echo "SIMVA is not initialized. Importing realm..." 
        docker compose exec keycloak /opt/keycloak/bin/kc.sh import --file "/opt/keycloak/data/import/simva-realm-full.json" --override false --optimized
    else
        echo "SIMVA is initialized." 
        migrationinProgressFile="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export/.migrationinprogress"
        if [[ -e "$migrationinProgressFile" ]]; then
            echo "Migration in progress. Importing realm..."
            realmFile="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export/${SIMVA_SSO_REALM:-simva}-realm.json" 
            if [[ -e "$realmFile" ]]; then
                docker compose exec keycloak /opt/keycloak/bin/kc.sh import --dir "/opt/keycloak/data/export/" --override true --optimized
            fi;
            rm -f $migrationinProgressFile
        fi;
    fi;
else
    echo "Please upgrade to a newer keycloak version ( > 18.*.*) before importing users and realm."
fi;