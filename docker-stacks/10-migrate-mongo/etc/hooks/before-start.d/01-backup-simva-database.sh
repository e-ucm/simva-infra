#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${SIMVA_HOME}/simva" backup 07-simva
"${SIMVA_HOME}/simva" restart 07-simva