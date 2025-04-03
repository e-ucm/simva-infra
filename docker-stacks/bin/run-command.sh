#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

: ${RUN_IN_CONTAINER:=false}
: ${RUN_IN_CONTAINER_NAME:=}
: ${RUN_IN_AS_SPECIFIC_USER:=}

function __docker_run_command()
{
    local container_name=$1
    shift;
    local specific_user=$1
    shift;
    if [[ ! ${specific_user} == "" ]]; then
        docker compose exec --user $specific_user -it ${container_name} "$@"
    else 
        docker compose exec -it ${container_name} "$@"
    fi
}

run_in_container=$RUN_IN_CONTAINER
container_name=$RUN_IN_CONTAINER_NAME
specific_user=$RUN_IN_AS_SPECIFIC_USER
case $run_in_container in
    "true" | 1)
        __docker_run_command "${container_name}" "${specific_user}" "$@"
        ;;
    *)
        "$@"
        ;;
esac