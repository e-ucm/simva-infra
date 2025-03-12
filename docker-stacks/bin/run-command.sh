#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

function __docker_run_command()
{
    local container_name=$1
    shift;
    docker compose exec -T ${container_name} "$@"
}

run_in_container=${RUN_IN_CONTAINER}
container_name=${RUN_IN_CONTAINER_NAME}
case $run_in_container in
    "true" | 1)
        __docker_run_command "${container_name}" "$@"
        ;;
    *)
        "$@"
        ;;
esac