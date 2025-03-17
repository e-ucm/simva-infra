#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

run_in_container=${RUN_IN_CONTAINER}
container_name=${RUN_IN_CONTAINER_NAME}
case $run_in_container in
    "true" | 1)
        keycloakContainer=$(echo $(docker compose ps --format '{{.Names}}' | grep "$container_name-1"))
        echo $keycloakContainer
        ;;
    *)
        echo true 
        ;;
esac