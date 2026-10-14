#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Removing Limesurvey simplesamlphp config data 
rm -rf "${SIMVA_DATA_HOME}/limesurvey${SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH:-/simplesamlphp}-data/config/*