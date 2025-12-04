#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="keycloak"

if [[ -e "${SIMVA_DATA_HOME}/keycloak/.initialized" ]]; then 
    echo "SIMVA is initialized." 
    exportinProgressFile="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.exportinprogress"
    if [[ -e "$exportinProgressFile" ]]; then
            echo "Migration in progress. Exporting realm..."
            # Check if the container is running
            source "${SIMVA_BIN_HOME}/check-docker-running.sh"
            set +e
            _check_docker_running
            ret=$?
            set -e
            echo $ret
            if [ $ret = 0 ]; then
                echo "Keycloak container is running. Launching export of users..."
                if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
                    ${SIMVA_BIN_HOME}/purge-folder-contents.sh "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/"
                    chmod -R ${SIMVA_KEYCLOAK_DIR_MODE} "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/"
                    "${SIMVA_BIN_HOME}/run-command.sh" /opt/keycloak/bin/kc.sh export --dir "/opt/keycloak/data/export/" --users different_files --users-per-file 100 --realm ${SIMVA_SSO_REALM} --optimized
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