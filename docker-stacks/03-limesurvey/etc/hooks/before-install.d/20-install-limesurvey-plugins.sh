#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

PLUGINS_DIR="${SIMVA_DATA_HOME}/limesurvey/plugins"
if [[ ! -d "${PLUGINS_DIR}" ]]; then
    mkdir "${PLUGINS_DIR}"
fi

DEPLOYMENT_DIR="${SIMVA_DATA_HOME}/limesurvey/data/plugins"

declare -A plugins=(["LimeSurveyWebhook"]=${SIMVA_LIMESURVEY_WEBHOOK_PLUGIN_VERSION} ["AuthOAuth2"]=${SIMVA_LIMESURVEY_AUTHOAUTH2_PLUGIN_VERSION} ["LimeSurveyXAPITracker"]=${SIMVA_LIMESURVEY_XAPITRACKER_PLUGIN_VERSION});

for key in "${!plugins[@]}"; do
    ext_name=$key
    ext_version=${plugins[$key]}
    echo "Key: $ext_name, Value: $ext_version"
    GIT_RELEASE_URL="https://github.com/e-ucm/$ext_name/releases/download/v${ext_version}"
    ext_zip="$ext_name-${ext_version}.zip"
    if [[ ! -f "${PLUGINS_DIR}/${ext_zip}" ]]; then
        wget -q -P "${PLUGINS_DIR}" "${GIT_RELEASE_URL}/${ext_zip}"
        chmod 777 "${PLUGINS_DIR}/${ext_zip}"
        shasums="SHA256SUMS-$ext_name-${ext_version}"
        if [[ ! -f "${PLUGINS_DIR}/${shasums}" ]]; then
            wget -q -O "${PLUGINS_DIR}/${shasums}" "${GIT_RELEASE_URL}/SHA256SUMS"
        fi
        pushd "${PLUGINS_DIR}"
        echo "$(cat "${PLUGINS_DIR}/${shasums}"  | grep "${ext_zip}" | cut -d' ' -f1) ${ext_zip}" | sha256sum -c -w -
        popd
    fi
    tmp_dir=$(mktemp -d)
    unzip "${PLUGINS_DIR}/${ext_zip}" -d $tmp_dir
    rsync -avh --delete --itemize-changes ${tmp_dir}/ "${DEPLOYMENT_DIR}/$ext_name"
done
