#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

OAUTH2_GIT_REPO_URL="https://github.com/SondagesPro/limesurvey-oauth2.git"
OAUTH2_GIT_REF="sondagespro"

# Create source folder
if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/data/plugins/AuthOAuth2" ]]; then 
    mkdir -p ${SIMVA_DATA_HOME}/limesurvey/data/plugins/AuthOAuth2

    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${OAUTH2_GIT_REF} ${OAUTH2_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;
    
    pushd $tmp_dir
    php /usr/local/bin/composer install
    popd

    rsync -avh --delete --itemize-changes ${tmp_dir}/ ${SIMVA_DATA_HOME}/limesurvey/data/plugins/AuthOAuth2 > /dev/null 2>&1
fi