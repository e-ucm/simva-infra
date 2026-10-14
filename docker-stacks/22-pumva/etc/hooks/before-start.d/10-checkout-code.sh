#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

RUNCHECKOUTCODE=false
RUNBUILDCODE=false
CHECKLOCALDEPLOYMENT=false
if [[ -f "$SIMVA_DATA_HOME/pumva/sqlite_initialisation_in_progress" ]]; then
    echo "Initialisation of the data in progress. Pass the execution."
    exit 0
fi
if [[ ! -e "${SIMVA_DATA_HOME}/pumva/.initialized" ]]; then
    echo "PUMVA is not initialized, initializing checkout code."
    RUNCHECKOUTCODE=true
fi
if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
    if [[ $SIMVA_DEVELOPMENT_LOCAL = "true" ]]; then
        echo "PUMVA is in local development environment, no checkout as code is local."
        RUNCHECKOUTCODE=false
        CHECKLOCALDEPLOYMENT=true
    else 
        echo "PUMVA is in development environment, launch checkout code."
        RUNCHECKOUTCODE=true
    fi
fi

source ${SIMVA_BIN_HOME}/check-checksum.sh;

if [[ ${RUNCHECKOUTCODE} = true ]] ; then
    SIMVA_PUMVA_GIT_REPO_URL=https://github.com/e-ucm/pumva.git
    SIMVA_PUMVA_GIT_REF=${SIMVA_PUMVA_GIT_REF:-master}

    SIMVA_PUMVA_FRONT_GIT_REPO_URL=https://github.com/e-ucm/pumva-front.git
    SIMVA_PUMVA_FRONT_GIT_REF=${SIMVA_PUMVA_FRONT_GIT_REF:-master}

    ###################################################################
    ############################# PUMVA ###############################
    ###################################################################
    # Create source folder (align with docker-compose build contexts)
    PUMVA_API_DIR="${SIMVA_PUMVA_GIT_REPO:-${SIMVA_DATA_HOME}/pumva/pumva-api}"
    mkdir -p "${PUMVA_API_DIR}"

    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_PUMVA_GIT_REF} ${SIMVA_PUMVA_GIT_REPO_URL} ${tmp_dir} > /dev/null  2>&1;
    set +e
    _check_checksum $tmp_dir "${SIMVA_DATA_HOME}/pumva/pumva-api-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        RUNBUILDCODE=true
    fi
    rsync -avh --delete --itemize-changes ${tmp_dir}/ "${PUMVA_API_DIR}/" > /dev/null 2>&1
    chmod -R "${SIMVA_NODE_DIR_MODE}" "${PUMVA_API_DIR}"
    rm -rf "${tmp_dir}"

    ###################################################################
    ########################### PUMVA FRONT ###########################
    ###################################################################
    # Create source folder (align with docker-compose build contexts)
    PUMVA_FRONT_DIR="${SIMVA_PUMVA_FRONT_GIT_REPO:-${SIMVA_DATA_HOME}/pumva/pumva-front}"
    mkdir -p "${PUMVA_FRONT_DIR}"

    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_PUMVA_FRONT_GIT_REF} ${SIMVA_PUMVA_FRONT_GIT_REPO_URL} ${tmp_dir} > /dev/null  2>&1;
    set +e
    _check_checksum $tmp_dir "${SIMVA_DATA_HOME}/pumva/pumva-front-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        RUNBUILDCODE=true
    fi
    rsync -avh --delete --itemize-changes ${tmp_dir}/ "${PUMVA_FRONT_DIR}/" > /dev/null 2>&1
    chmod -R "${SIMVA_NODE_DIR_MODE}" "${PUMVA_FRONT_DIR}"
    rm -rf "${tmp_dir}"
fi

if [[ ${CHECKLOCALDEPLOYMENT} == true ]] ; then
    ###################################################################
    ############################# PUMVA ############################### 
    ###################################################################
    echo "PUMVA"
    set +e
    _check_checksum ${SIMVA_PUMVA_GIT_REPO} "${SIMVA_DATA_HOME}/pumva/pumva-api-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        rm -rf ${SIMVA_PUMVA_GIT_REPO}/node_modules
        RUNBUILDCODE=true
    fi

    ###################################################################
    ########################### PUMVA FRONT ###########################
    ###################################################################
    echo "PUMVA FRONT"
    set +e
    _check_checksum ${SIMVA_PUMVA_FRONT_GIT_REPO} "${SIMVA_DATA_HOME}/pumva/pumva-front-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        rm -rf ${SIMVA_PUMVA_FRONT_GIT_REPO}/node_modules
        RUNBUILDCODE=true
    fi
fi

if [[ ${RUNBUILDCODE} = true ]] ; then
    exec ${SIMVA_HOME}/simva build ./10-pumva
fi
