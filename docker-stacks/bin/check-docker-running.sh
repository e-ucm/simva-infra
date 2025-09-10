#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

: ${RUN_IN_CONTAINER:=false}
: ${RUN_IN_CONTAINER_NAME:=}

_check_docker_running() {
    run_in_container=${RUN_IN_CONTAINER}
    container_name=${RUN_IN_CONTAINER_NAME}
    case $run_in_container in
        "true" | 1)
            container=$(echo $(docker compose ps --format '{{.Names}}' | grep "$container_name-1"))
            if [[ $container != "" ]]; then 
                return 0;
            else 
                return 1;
             fi
            ;;
        *)
            return 1;
            ;;
    esac
}