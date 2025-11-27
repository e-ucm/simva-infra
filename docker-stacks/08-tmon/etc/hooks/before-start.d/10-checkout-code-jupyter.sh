#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

SIMVA_TMON_GIT_REPO_URL=https://github.com/e-ucm/t-mon.git
SIMVA_TMON_GIT_REF=${SIMVA_TMON_ANACONDA_GIT_REF:-master-jupyter-notebook}

RUNCHECKOUTCODE=false
if [[ "${SIMVA_ENVIRONMENT}" == "development" ]] ; then
    echo "SIMVA is in development environment, launch checkout code."
    RUNCHECKOUTCODE=true
fi
if [[ ${RUNCHECKOUTCODE} == true ]] ; then
    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME}/anaconda/notebooks/t-mon
    
    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_TMON_GIT_REF} ${SIMVA_TMON_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;
    rsync -avh --delete --itemize-changes ${tmp_dir}/ ${SIMVA_DATA_HOME}/anaconda/notebooks/t-mon/ > /dev/null 2>&1
    sudo chmod -R 777 ${SIMVA_DATA_HOME}/anaconda/notebooks/t-mon/
fi