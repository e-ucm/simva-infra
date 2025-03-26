#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_ENVIRONMENT}" != "development" ]]; then exit 0; fi;

if [[ "${SIMVA_ENABLE_DEBUG_PROFILING}" = "false" ]]; then exit 0; fi;

source "${SIMVA_HOME}/bin/check-docker-running.sh"
export RUN_IN_CONTAINER=true
container_list="simva-trace-allocator simva-front simva-api"

for container_name in $container_list; do
    export RUN_IN_CONTAINER_NAME=$container_name
    docker compose kill -s SIGINT $RUN_IN_CONTAINER_NAME 
    isStopped="false"
    while [[ $isStopped = "false" ]]; do
        # Check if the container is running        
        set +e
        _check_docker_running
        ret=$?
        set -e
        echo $ret
        if [ $ret != 0 ]; then
            isStopped="true";
            echo "$RUN_IN_CONTAINER_NAME stopped."
        else 
            echo "$RUN_IN_CONTAINER_NAME not stopped. Wait 10 seconds"
            sleep 10;
        fi;
    done
done