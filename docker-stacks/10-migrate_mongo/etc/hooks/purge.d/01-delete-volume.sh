#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${SIMVA_BIN_HOME}/volumectl.sh" delete "simva_mysql_data"