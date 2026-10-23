#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source "${SIMVA_BIN_HOME}/extension-helper.sh"

# The simva containers mount xasu-js from SIMVA_XASUJS_LIBRARY_LOCAL_PATH in local deployment: fetch it if missing.
if [[ "${SIMVA_XASUJS_LIBRARY_LOCAL_DEPLOYMENT:-false}" == "true" ]]; then
    checkout_local_repo "${SIMVA_XASUJS_LIBRARY_LOCAL_PATH}" "xasu-js" "${SIMVA_XASUJS_GIT_REF:-master}"
fi
