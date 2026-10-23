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
source "${SIMVA_BIN_HOME}/extension-helper.sh"

# Function to checkout code from git repository
checkout_repository() {
    local repo_url=$1
    local git_ref=$2
    local target_dir=$3
    
    mkdir -p ${target_dir}
    local tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${git_ref} ${repo_url} ${tmp_dir} > /dev/null
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
    SIMVA_API_REF="$(resolve_git_ref simva "v${SIMVA_SIMVA_VERSION}")"

    SIMVA_FRONT_GIT_REPO_URL=https://github.com/e-ucm/simva-front.git
    SIMVA_FRONT_REF="$(resolve_git_ref simva-front "v${SIMVA_SIMVA_FRONT_VERSION}")"

    SIMVA_TRACE_ALLOCATOR_GIT_REPO_URL=https://github.com/e-ucm/simva-trace-allocator.git
    SIMVA_TRACE_ALLOCATOR_REF="$(resolve_git_ref simva-trace-allocator "v${SIMVA_SIMVA_TRACE_ALLOCATOR_VERSION}")"
    ###########################################################
    ######################### BACKEND #########################
    ###########################################################

    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME}/simva/simva-api

    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_API_REF} ${SIMVA_API_GIT_REPO_URL} ${tmp_dir} > /dev/null;
    
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
    git clone --depth 1 --branch ${SIMVA_FRONT_REF} ${SIMVA_FRONT_GIT_REPO_URL} ${tmp_dir} > /dev/null;
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
    git clone --depth 1 --branch ${SIMVA_TRACE_ALLOCATOR_REF} ${SIMVA_TRACE_ALLOCATOR_GIT_REPO_URL} ${tmp_dir} > /dev/null;
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
fi
if [[ ${CHECKLOCALDEPLOYMENT} == true ]] ; then
    # Local sources are expected next to simva-infra: fetch the missing ones (existing folders are kept).
    checkout_local_repo "${SIMVA_API_GIT_REPO}"             "simva"                  "v${SIMVA_SIMVA_VERSION}"
    checkout_local_repo "${SIMVA_FRONT_GIT_REPO}"           "simva-front"            "v${SIMVA_SIMVA_FRONT_VERSION}"
    checkout_local_repo "${SIMVA_TRACE_ALLOCATOR_GIT_REPO}" "simva-trace-allocator"  "v${SIMVA_SIMVA_TRACE_ALLOCATOR_VERSION}"
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
    # Only the development compose files declare a build context, the other environments run the
    # published images, so checking the code out must not trigger a build there.
    if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
        exec ${SIMVA_HOME}/simva build ${CURRENT_STACK}
    else
        echo "SIMVA is in ${SIMVA_ENVIRONMENT} environment, no image built, the published images are used."
    fi
fi