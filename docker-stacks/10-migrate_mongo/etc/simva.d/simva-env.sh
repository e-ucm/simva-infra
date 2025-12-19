#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export MYSQL_ROOT_HOST=$(echo $SIMVA_NETWORK_CIDR | cut -d'/' -f1 | awk -F. '{print $1 "." $2 "." $3 ".%"}')
export COMPOSE_FILE="docker-compose.yml:docker-compose.dev.yml"