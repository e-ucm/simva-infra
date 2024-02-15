#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x



SIMVA_API_GIT_REPO_URL=https://github.com/e-ucm/simva.git
SIMVA_API_GIT_REF=${SIMVA_API_GIT_REF:-master}

SIMVA_FRONT_GIT_REPO_URL=https://github.com/e-ucm/simva-front.git
SIMVA_FRONT_GIT_REF=${SIMVA_FRONT_GIT_REF:-master}

SIMVA_TRACE_ALLOCATOR_GIT_REPO_URL=https://github.com/e-ucm/simva-trace-allocator.git
SIMVA_TRACE_ALLOCATOR_GIT_REF=${SIMVA_TRACE_ALLOCATOR_GIT_REF:-master}

RUNCHECKOUTCODE=false
if [[ ! -e "${SIMVA_PROJECT_DIR}/.simva-initialized" ]]; then
    echo "SIMVA it is not initialized, initializing checkout code."
    RUNCHECKOUTCODE=true
fi
if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]] ; then
    echo "SIMVA is in development environment, launch checkout code."
    RUNCHECKOUTCODE=true
fi
if [[ ${RUNCHECKOUTCODE} == true ]] ; then

    ###########################################################
    ######################### BACKEND #########################
    ###########################################################

    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-api
    
    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_API_GIT_REF} ${SIMVA_API_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;

    # Calculate checksums of package.json and package-lock.json
    pushd ${tmp_dir} > /dev/null 2>&1
    sha256sum package.json package-lock.json > sha256sums
    popd > /dev/null 2>&1

    # Verify checksums of current files
    newSha=$(cat ${tmp_dir}/sha256sums)
    if [ -e "${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-api/sha256sums" ] ; then 
        oldSha=$(cat ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-api/sha256sums)
    else 
        oldSha=""
    fi
    echo $oldSha
    echo $newSha

    # If checksums do not verify -> reinstall dependencies
    rsync_opts="--exclude node_modules"
    if [[ ! ${newSha} == ${oldSha} ]]; then
        rsync_opts=""
    fi
    echo $rsync_opts
    rsync -avh --delete --itemize-changes ${rsync_opts} ${tmp_dir}/ ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-api/ > /dev/null 2>&1

    ############################################################
    ######################### FRONTEND #########################
    ############################################################

    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-front
    
    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_FRONT_GIT_REF} ${SIMVA_FRONT_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;

    # Calculate checksums of package.json and package-lock.json
    pushd ${tmp_dir} > /dev/null 2>&1
    sha256sum package.json package-lock.json > sha256sums
    popd > /dev/null 2>&1

    # Verify checksums of current files
    newSha=$(cat ${tmp_dir}/sha256sums)
    if [ -e "${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-front/sha256sums" ]; then 
        oldSha=$(cat ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-front/sha256sums)
    else 
        oldSha=""
    fi
    echo $oldSha
    echo $newSha

    # If checksums do not verify -> reinstall dependencies
    rsync_opts="--exclude node_modules"
    if [[ ! ${newSha} == ${oldSha} ]]; then
        rsync_opts=""
    fi
    echo $rsync_opts
    rsync -avh --delete --itemize-changes ${rsync_opts} ${tmp_dir}/ ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-front/ > /dev/null 2>&1

    ###################################################################
    ######################### TRACE ALLOCATOR #########################
    ###################################################################

    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-trace-allocator
    
    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_TRACE_ALLOCATOR_GIT_REF} ${SIMVA_TRACE_ALLOCATOR_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;

    # Calculate checksums of package.json and package-lock.json
    pushd ${tmp_dir} > /dev/null 2>&1
    sha256sum package.json package-lock.json > sha256sums
    popd > /dev/null 2>&1

    # Verify checksums of current files
    newSha=$(cat ${tmp_dir}/sha256sums)
    if [ -e "${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-trace-allocator/sha256sums" ]; then 
        oldSha=$(cat ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-trace-allocator/sha256sums)
    else 
        oldSha=""
    fi
    echo $oldSha
    echo $newSha

    # If checksums do not verify -> reinstall dependencies
    rsync_opts="--exclude node_modules"
    if [[ ! ${newSha} == ${oldSha} ]]; then
        rsync_opts=""
    fi
    echo $rsync_opts
    rsync -avh --delete --itemize-changes ${rsync_opts} ${tmp_dir}/ ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-trace-allocator/ > /dev/null 2>&1
fi
