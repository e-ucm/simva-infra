#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Ensure security.php and config.php can be created
touch "${SIMVA_CONFIG_HOME}/limesurvey/etc/security.php"
touch "${SIMVA_CONFIG_HOME}/limesurvey/etc/config.php"