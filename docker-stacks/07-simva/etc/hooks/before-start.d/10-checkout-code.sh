#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

RUNCHECKOUTCODE=false
RUNBUILDCODE=false
CHECKLOCALDEPLOYMENT=false
if [[ ! -e "${SIMVA_DATA_HOME}/simva/.initialized" ]]; then
    echo "SIMVA it is not initialized, initializing checkout code."
    chmod -R 777 ${SIMVA_DATA_HOME}/simva/simva-api-logs
    chmod -R 777 ${SIMVA_DATA_HOME}/simva/simva-api-data-logs
    chmod -R 777 ${SIMVA_DATA_HOME}/simva/simva-front-logs
    chmod -R 777 ${SIMVA_DATA_HOME}/simva/simva-trace-allocator-logs
    mkdir -p ${SIMVA_DATA_HOME}/simva/simva-api-profiling
    chmod -R 777 ${SIMVA_DATA_HOME}/simva/simva-api-profiling
    mkdir -p ${SIMVA_DATA_HOME}/simva/simva-api-data-profiling
    chmod -R 777 ${SIMVA_DATA_HOME}/simva/simva-api-data-profiling
    mkdir -p ${SIMVA_DATA_HOME}/simva/simva-front-profiling
    chmod -R 777 ${SIMVA_DATA_HOME}/simva/simva-front-profiling
    mkdir -p ${SIMVA_DATA_HOME}/simva/simva-trace-allocator-profiling
    chmod -R 777 ${SIMVA_DATA_HOME}/simva/simva-trace-allocator-profiling
    RUNCHECKOUTCODE=true
fi
if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
    if [[ $SIMVA_DEVELOPMENT_LOCAL = "true" ]]; then
        echo "SIMVA is in local development environment, no checkout as code is local."
        RUNCHECKOUTCODE=false
        CHECKLOCALDEPLOYMENT=true
    else 
        echo "SIMVA is in development environment, launch checkout code."
        RUNCHECKOUTCODE=true
    fi
fi

source ${SIMVA_HOME}/bin/check-checksum.sh;

if [[ ${RUNCHECKOUTCODE} = true ]] ; then
    SIMVA_API_GIT_REPO_URL=https://github.com/e-ucm/simva.git
    SIMVA_API_GIT_REF=${SIMVA_API_GIT_REF:-master}

    SIMVA_FRONT_GIT_REPO_URL=https://github.com/e-ucm/simva-front.git
    SIMVA_FRONT_GIT_REF=${SIMVA_FRONT_GIT_REF:-master}

    SIMVA_TRACE_ALLOCATOR_GIT_REPO_URL=https://github.com/e-ucm/simva-trace-allocator.git
    SIMVA_TRACE_ALLOCATOR_GIT_REF=${SIMVA_TRACE_ALLOCATOR_GIT_REF:-master}
    ###########################################################
    ######################### BACKEND #########################
    ###########################################################

    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME}/simva/simva-api

    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_API_GIT_REF} ${SIMVA_API_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;
    
    set +e
    _check_checksum $tmp_dir "${SIMVA_DATA_HOME}/simva/simva-api-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        RUNBUILDCODE=true
    fi
    rsync -avh --delete --itemize-changes ${tmp_dir}/ ${SIMVA_DATA_HOME}/simva/simva-api/ > /dev/null 2>&1

    ############################################################
    ######################### FRONTEND #########################
    ############################################################

    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME}/simva/simva-front
    
    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_FRONT_GIT_REF} ${SIMVA_FRONT_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;
    set +e
    _check_checksum $tmp_dir "${SIMVA_DATA_HOME}/simva/simva-front-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        RUNBUILDCODE=true
    fi
    rsync -avh --delete --itemize-changes ${tmp_dir}/ ${SIMVA_DATA_HOME}/simva/simva-front/ > /dev/null 2>&1

    ###################################################################
    ######################### TRACE ALLOCATOR #########################
    ###################################################################
    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME}/simva/simva-trace-allocator
    
    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_TRACE_ALLOCATOR_GIT_REF} ${SIMVA_TRACE_ALLOCATOR_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;
    set +e
    _check_checksum $tmp_dir "${SIMVA_DATA_HOME}/simva/simva-trace-allocator-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        RUNBUILDCODE=true
    fi
    rsync -avh --delete --itemize-changes ${tmp_dir}/ ${SIMVA_DATA_HOME}/simva/simva-trace-allocator/ > /dev/null 2>&1
    chmod -R 777 ${SIMVA_DATA_HOME}/simva
fi
if [[ ${CHECKLOCALDEPLOYMENT} == true ]] ; then
    ###########################################################
    ######################### BACKEND #########################
    ###########################################################
    echo "SIMVA API"
    set +e
    _check_checksum ${SIMVA_API_GIT_REPO} "${SIMVA_DATA_HOME}/simva/simva-api-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        rm -rf ${SIMVA_API_GIT_REPO}/node_modules
        RUNBUILDCODE=true
    fi
    ###################################################################
    ############################# FRONTEND ############################
    ################################################################### 
    echo "SIMVA FRONT"
    set +e
    _check_checksum ${SIMVA_FRONT_GIT_REPO} "${SIMVA_DATA_HOME}/simva/simva-front-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        rm -rf ${SIMVA_FRONT_GIT_REPO}/node_modules
        RUNBUILDCODE=true
    fi
    ###################################################################
    ######################### TRACE ALLOCATOR #########################
    ###################################################################
    echo "SIMVA TRACE ALLOCATOR"
    set +e
    _check_checksum ${SIMVA_TRACE_ALLOCATOR_GIT_REPO} "${SIMVA_DATA_HOME}/simva/simva-trace-allocator-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        rm -rf ${SIMVA_TRACE_ALLOCATOR_GIT_REPO}/node_modules
        RUNBUILDCODE=true
    fi
fi
if [[ ${RUNBUILDCODE} = true ]] ; then
    exec ${SIMVA_HOME}/simva build ./07-simva
fi