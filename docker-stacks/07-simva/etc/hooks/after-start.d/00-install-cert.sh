#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="root"

export RUN_IN_CONTAINER_NAME="simva-api"
"${SIMVA_BIN_HOME}/run-command.sh" /bin/bash /home/node/entrypoint.d/docker-certificate.sh

export RUN_IN_CONTAINER_NAME="simva-front"
"${SIMVA_BIN_HOME}/run-command.sh" /bin/bash /home/node/entrypoint.d/docker-certificate.sh

export RUN_IN_CONTAINER_NAME="simva-trace-allocator"
"${SIMVA_BIN_HOME}/run-command.sh" /bin/bash /home/node/entrypoint.d/docker-certificate.sh