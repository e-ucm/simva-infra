#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

WEBHOOK_GIT_REPO_URL="https://github.com/e-ucm/LimeSurveyWebhook.git"
WEBHOOK_GIT_REF="adding-survey-begining"

# Create source folder
if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/data/plugins/LimeSurveyWebhook" ]]; then 
    mkdir -p ${SIMVA_DATA_HOME}/limesurvey/data/plugins/LimeSurveyWebhook    
fi

# Checkout code in temp dir
tmp_dir=$(mktemp -d)
git clone --depth 1 --branch ${WEBHOOK_GIT_REF} ${WEBHOOK_GIT_REPO_URL} ${tmp_dir} > /dev/null 2>&1;

rsync -avh --delete --itemize-changes ${tmp_dir}/ ${SIMVA_DATA_HOME}/limesurvey/data/plugins/LimeSurveyWebhook > /dev/null 2>&1