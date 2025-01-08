#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/wait-available.sh "SIMVA Front" "https://${SIMVA_EXTERNAL_DOMAIN}" "true" "false"