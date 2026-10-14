#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="connect"
export RUN_IN_AS_SPECIFIC_USER="root"

"${SIMVA_BIN_HOME}/run-command.sh" '/usr/share/entrypoint.d/docker-startup.sh'