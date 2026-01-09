#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

RUNCHECKOUTCODE=false
RUNBUILDCODE=false
CHECKLOCALDEPLOYMENT=false
if [[ ! -e "${SIMVA_DATA_HOME}/simva/.initialized" ]]; then
    echo "SIMVA it is not initialized, initializing checkout code."
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

source ${SIMVA_BIN_HOME}/check-checksum.sh;

# Function to checkout code from git repository
checkout_repository() {
    local repo_url=$1
    local git_ref=$2
    local target_dir=$3
    
    mkdir -p ${target_dir}
    local tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${git_ref} ${repo_url} ${tmp_dir} > /dev/null 2>&1
    rsync -avh --delete --itemize-changes ${tmp_dir}/ ${target_dir}/ > /dev/null 2>&1
    rm -rf ${tmp_dir}
    echo "${target_dir}"
}

# Function to check checksum and set rebuild flag
check_and_rebuild() {
    local source_dir=$1
    local checksum_file=$2
    local files_to_check=$3
    
    set +e
    _check_checksum ${source_dir} "${checksum_file}" "${files_to_check}"
    local ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        return 0  # needs rebuild
    fi
    return 1  # no rebuild needed
}

if [[ ${RUNCHECKOUTCODE} = true ]] ; then
    SIMVA_API_GIT_REPO_URL=https://github.com/e-ucm/simva.git
    SIMVA_API_GIT_REF=${SIMVA_API_GIT_REF:-master}

    SIMVA_FRONT_GIT_REPO_URL=https://github.com/e-ucm/simva-front.git
    SIMVA_FRONT_GIT_REF=${SIMVA_FRONT_GIT_REF:-master}

    SIMVA_TRACE_ALLOCATOR_GIT_REPO_URL=https://github.com/e-ucm/simva-trace-allocator.git
    SIMVA_TRACE_ALLOCATOR_GIT_REF=${SIMVA_TRACE_ALLOCATOR_GIT_REF:-master}

    SIMVA_PUMVA_GIT_REPO_URL=https://github.com/e-ucm/pumva.git
    SIMVA_PUMVA_GIT_REF=${SIMVA_PUMVA_GIT_REF:-master}
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
    chmod -R ${SIMVA_NODE_DIR_MODE} ${SIMVA_DATA_HOME}/simva

    ###################################################################
    ############################# PUMVA ###############################
    ###################################################################
    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME}/pumva

    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_PUMVA_GIT_REF} ${SIMVA_PUMVA_GIT_REPO_URL} ${tmp_dir} > /dev/null  2>&1;
    set +e
    _check_checksum $tmp_dir "${SIMVA_DATA_HOME}/pumva/pumva-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        RUNBUILDCODE=true
    fi
    rsync -avh --delete --itemize-changes ${tmp_dir}/ ${SIMVA_DATA_HOME}/pumva/ > /dev/null 2>&1
    chmod -R ${SIMVA_NODE_DIR_MODE} ${SIMVA_DATA_HOME}/pumva
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

    ###################################################################
    ############################# PUMVA ############################### 
    ###################################################################
    echo "PUMVA"
    set +e
    _check_checksum ${SIMVA_PUMVA_GIT_REPO} "${SIMVA_DATA_HOME}/pumva/pumva-sha256sums" "Dockerfile package.json package-lock.json"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        rm -rf ${SIMVA_PUMVA_GIT_REPO}/node_modules
        RUNBUILDCODE=true
    fi
fi
if [[ ${RUNBUILDCODE} = true ]] ; then
    exec ${SIMVA_HOME}/simva build ./07-simva
fi