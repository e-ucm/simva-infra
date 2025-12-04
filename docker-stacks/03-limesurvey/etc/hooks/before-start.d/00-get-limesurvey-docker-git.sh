#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

RUNCHECKOUTCODE=false
RUNBUILDCODE=false
CHECKLOCALDEPLOYMENT=false
if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/.initialized" ]]; then
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

if [[ ${RUNCHECKOUTCODE} = true ]] ; then
    DOCKER_LIMESURVEY_GIT_REPO_URL=https://github.com/e-ucm/docker-limesurvey.git
    DOCKER_LIMESURVEY_GIT_REF=${SIMVA_LIMESURVEY_DOCKER_GIT_REF:-master}

    ###########################################################
    #################### DOCKER LIMESURVEY ####################
    ###########################################################

    # Create source folder
    mkdir -p ${SIMVA_LIMESURVEY_DOCKER_GIT_REPO}

    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${DOCKER_LIMESURVEY_GIT_REF} ${DOCKER_LIMESURVEY_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;
    
    set +e
    _check_checksum $tmp_dir "${SIMVA_DATA_HOME}/limesurvey/limesurvey-docker-sha256sums" "Dockerfile"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        RUNBUILDCODE=true
    fi
    rsync -avh --delete --itemize-changes ${tmp_dir}/ ${SIMVA_LIMESURVEY_DOCKER_GIT_REPO} > /dev/null 2>&1
fi
if [[ ${CHECKLOCALDEPLOYMENT} == true ]] ; then
    ###########################################################
    #################### DOCKER LIMESURVEY ####################
    ###########################################################
    echo "Limesurvey Docker"
    set +e
    _check_checksum ${SIMVA_LIMESURVEY_DOCKER_GIT_REPO} "${SIMVA_DATA_HOME}/limesurvey/limesurvey-docker-sha256sums" "Dockerfile"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        RUNBUILDCODE=true
    fi
fi
if [[ ${RUNBUILDCODE} = true ]] ; then
    exec ${SIMVA_HOME}/simva build ${CURRENT_STACK}
fi