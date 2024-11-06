#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -e "${SIMVA_DATA_HOME}/keycloak/.initialized" ]]; then 
    echo "SIMVA is initialized." 
    exportinProgressFile="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.exportinprogress"
    if [[ -e "$exportinProgressFile" ]]; then
            echo "Migration in progress. Exporting realm..."
            # Check if the container is running
            keycloakContainer=$(echo $(docker ps --format '{{.Names}}' | grep "keycloak-1"))
            if [ ! $keycloakContainer = "" ]; then
                echo "Keycloak container is running. Launching export of users..."
                if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
                    ${SIMVA_HOME}/bin/purge-folder-contents.sh "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/"
                    chmod a+w "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/"
                    docker compose exec keycloak /opt/keycloak/bin/kc.sh export --dir "/opt/keycloak/data/export/" --users different_files --users-per-file 100 --realm ${SIMVA_SSO_REALM} --optimized
                    rm -f $exportinProgressFile
                else
                    echo "Please upgrade to a newer keycloak version ( > 18.*.*) before exporting users and realm."
                fi
            else
                echo "Keycloak container is not running."
            fi
    else 
        echo "Nothing to do. No migration detected."
    fi
fi