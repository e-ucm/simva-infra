#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

chmod -R a+w ${SIMVA_DATA_HOME}/simva/simva-trace-allocator-data