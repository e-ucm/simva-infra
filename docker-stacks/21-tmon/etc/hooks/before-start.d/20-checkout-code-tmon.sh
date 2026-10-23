#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

RUNCHECKOUTCODE=false
RUNBUILDCODE=false
CHECKLOCALDEPLOYMENT=false
if [[ ! -e "${SIMVA_DATA_HOME}/tmon/.initialized" ]]; then
    echo "SIMVA it is not initialized, initializing checkout code."
    RUNCHECKOUTCODE=true
fi
if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
    if [[ $SIMVA_DEVELOPMENT_LOCAL == "true" ]]; then
        echo "SIMVA is in local development environment, no checkout as code is local."
        RUNCHECKOUTCODE=false
        CHECKLOCALDEPLOYMENT=true
    else 
        echo "SIMVA is in development environment, launch checkout code."
        RUNCHECKOUTCODE=true
    fi
fi

if [[ ${RUNCHECKOUTCODE} == true ]] ; then
    SIMVA_TMON_GIT_REPO_URL=https://github.com/e-ucm/t-mon.git
    # the checked out ref follows the installed version (tag vX.Y.Z), SIMVA_TMON_GIT_REF overrides it
    SIMVA_TMON_GIT_REF=${SIMVA_TMON_GIT_REF:-v${SIMVA_TMON_VERSION}}

    ###########################################################
    ########################### TMON ##########################
    ###########################################################
    # Create source folder
    mkdir -p ${SIMVA_DATA_HOME}/tmon/t-mon/
    
    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_TMON_GIT_REF} ${SIMVA_TMON_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;
    source ${SIMVA_HOME}/bin/check-checksum.sh
    set +e
    _check_checksum $tmp_dir "${SIMVA_DATA_HOME}/tmon/tmon-sha256sums" "requirements.txt"
    res=$?
    set -e
    echo $res
    # If checksums do not verify -> reinstall dependencies
    if [[ ! $res == "0" ]]; then
        RUNBUILDCODE=true
    fi
    rsync -avh --delete --itemize-changes ${tmp_dir}/ ${SIMVA_DATA_HOME}/tmon/t-mon/ > /dev/null 2>&1
    chmod -R ${SIMVA_TMON_DIR_MODE} ${SIMVA_DATA_HOME}/tmon/t-mon/
fi
if [[ ${CHECKLOCALDEPLOYMENT} == true ]] ; then
    ###########################################################
    ########################### TMON ##########################
    ###########################################################
    echo "TMON"
    # Local sources are expected next to simva-infra: fetch them if missing (an existing folder is kept).
    source "${SIMVA_BIN_HOME}/extension-helper.sh"
    checkout_local_repo "${SIMVA_TMON_GIT_REPO}" "t-mon" "v${SIMVA_TMON_VERSION}"
    source ${SIMVA_HOME}/bin/check-checksum.sh
    set +e
    _check_checksum ${SIMVA_TMON_GIT_REPO} "${SIMVA_DATA_HOME}/tmon/tmon-sha256sums" "requirements.txt"
    res=$?
    set -e
    echo $res
    if [[ ! $res == "0" ]]; then
        RUNBUILDCODE=true
    fi
    chmod -R ${SIMVA_TMON_DIR_MODE} ${SIMVA_TMON_GIT_REPO}
fi
if [[ ${RUNBUILDCODE} == true ]] ; then
    # Only the development compose files declare a build context, the other environments run the
    # published images, so checking the code out must not trigger a build there.
    if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
        exec ${SIMVA_HOME}/simva build ${CURRENT_STACK}
    else
        echo "TMON is in ${SIMVA_ENVIRONMENT} environment, no image built, the published images are used."
    fi
fi