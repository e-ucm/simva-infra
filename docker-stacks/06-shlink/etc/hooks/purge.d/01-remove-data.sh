#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${SIMVA_HOME}/bin/volumectl.sh" delete "shlink_db"