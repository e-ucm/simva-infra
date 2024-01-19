#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

CSP_REPORTER_GIT_REPO_URL=https://github.com/radiovisual/local-csp-reporter/
CSP_REPORTER_GIT_REF=${CSP_REPORTER_GIT_REF:-master}

if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then

    ###########################################################
    ####################### CSP-REPORTER ######################
    ###########################################################

    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/traefik/csp-reporter
    
    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${CSP_REPORTER_GIT_REF} ${CSP_REPORTER_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;

    # Calculate checksums of package.json and package-lock.json
    pushd ${tmp_dir} > /dev/null 2>&1
    sha256sum package.json > sha256sums
    popd > /dev/null 2>&1

    # Verify checksusms of current files
    pushd ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/traefik/csp-reporter > /dev/null 2>&1
    old_bash_opts=$-
    set +e
    sha256sum -c --status ${tmp_dir}/sha256sums

    # If checksums do not verify -> reinstall dependencies
    reinstall_deps=$?
    if [[ ${old_bash_opts} =~ e ]]; then
        set -e
    fi

    popd > /dev/null 2>&1
    rsync_opts="--exclude node_modules"
    if [[ ${reinstall_deps} -ne 0 ]]; then
        rsync_opts=""
    fi
    rsync -avh --delete --itemize-changes ${rsync_opts} ${tmp_dir}/ ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/traefik/csp-reporter/ > /dev/null 2>&1
fi
