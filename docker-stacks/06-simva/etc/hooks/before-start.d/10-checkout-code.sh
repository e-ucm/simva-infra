#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x



SIMVA_API_GIT_REPO_URL=https://github.com/e-ucm/simva.git
SIMVA_API_GIT_REF=${SIMVA_API_GIT_REF:-dev}

SIMVA_FRONT_GIT_REPO_URL=https://github.com/e-ucm/simva-front.git
SIMVA_FRONT_GIT_REF=${SIMVA_FRONT_GIT_REF:-dev}

SIMVA_TRACE_ALLOCATOR_GIT_REPO_URL=https://github.com/e-ucm/simva-trace-allocator.git
SIMVA_TRACE_ALLOCATOR_GIT_REF=${SIMVA_TRACE_ALLOCATOR_GIT_REF:-dev}

if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then

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

    # Verify checksusms of current files
    pushd ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-api > /dev/null 2>&1
    old_bash_opts=$-
    set +e
    sha256sum -c --status ${tmp_dir}/sha256sums

    # If checksums do not verify -> reinstall dependencies
    reinstall_deps=$?
    if [[ ${old_bash_opts} =~ e ]]; then
        set -e
    fi

    popd > /dev/null 2>&1
    rsync_opts="--exclude .gitignore"
    if [[ ${reinstall_deps} -eq 0 ]]; then
        rsync_opts="--exclude node_modules"
    fi
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

    # Verify checksusms of current files
    pushd ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-front > /dev/null 2>&1
    old_bash_opts=$-
    set +e
    sha256sum -c --status ${tmp_dir}/sha256sums

    # If checksums do not verify -> reinstall dependencies
    reinstall_deps=$?
    if [[ ${old_bash_opts} =~ e ]]; then
        set -e
    fi
    popd > /dev/null 2>&1
    rsync_opts="--exclude .gitignore"
    if [[ ${reinstall_deps} -eq 0 ]]; then
        rsync_opts="--exclude node_modules"
    fi
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

    # Verify checksusms of current files
    pushd ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-trace-allocator > /dev/null 2>&1
    old_bash_opts=$-
    set +e
    sha256sum -c --status ${tmp_dir}/sha256sums

    # If checksums do not verify -> reinstall dependencies
    reinstall_deps=$?
    if [[ ${old_bash_opts} =~ e ]]; then
        set -e
    fi
    popd > /dev/null 2>&1
    rsync_opts="--exclude .gitignore"
    if [[ ${reinstall_deps} -eq 0 ]]; then
        rsync_opts="--exclude node_modules"
    fi
    rsync -avh --delete --itemize-changes ${rsync_opts} ${tmp_dir}/ ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva/simva-trace-allocator/ > /dev/null 2>&1
fi
