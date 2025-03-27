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
            docker compose exec -it $container_name ps -ef --forest
            docker compose kill -s SIGINT $container_name
            echo "$container_name not stopped. Wait ${SIMVA_CLINIC_SCRIPT_WAIT_TIME} seconds"
            sleep ${SIMVA_CLINIC_SCRIPT_WAIT_TIME};
        fi;
    done
done