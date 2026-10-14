#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Source the extension helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SIMVA_BIN_HOME}/extension-helper.sh"

PLUGINS_DIR="${SIMVA_DATA_HOME}/limesurvey/plugins"
DEPLOYMENT_DIR="${SIMVA_DATA_HOME}/limesurvey/data/plugins"
ensure_dir "${PLUGINS_DIR}"
ensure_dir "${DEPLOYMENT_DIR}"

declare -A plugins=(
    ["LimeSurveyWebhook"]=${SIMVA_LIMESURVEY_WEBHOOK_PLUGIN_VERSION}
    ["AuthOAuth2"]=${SIMVA_LIMESURVEY_AUTHOAUTH2_PLUGIN_VERSION}
    ["LimeSurveyXAPITracker"]=${SIMVA_LIMESURVEY_XAPITRACKER_PLUGIN_VERSION}
)

SIMVA_LIMESURVEY_PLUGIN_LOCAL_DEPLOYMENT="${SIMVA_LIMESURVEY_PLUGIN_LOCAL_DEPLOYMENT:-false}"
SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH="${SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH:-}"

build_local_plugin_zip() {
    local plugin_path="$1"
    local plugin_name="$2"
    local plugin_version="$3"
    local zip_file_name="$4"

    local built_zip_path="${plugin_path}/builds-${plugin_version}/${zip_file_name}"

    if [[ ! -d "${plugin_path}" ]]; then
        echo "ERROR: Local plugin path does not exist: ${plugin_path}"
        return 1
    fi

    if [[ ! -x "${plugin_path}/build.sh" ]]; then
        echo "ERROR: build.sh not found or not executable in ${plugin_path}"
        return 1
    fi

    echo "Building local plugin ${plugin_name} (${plugin_version})..."
    pushd "${plugin_path}" > /dev/null
    ./build.sh -b "${plugin_version}"
    popd > /dev/null

    if [[ ! -f "${built_zip_path}" ]]; then
        echo "ERROR: Local plugin ZIP not found after build: ${built_zip_path}"
        return 1
    fi

    cp "${built_zip_path}" "${PLUGINS_DIR}/${zip_file_name}"
    chmod -R "${SIMVA_LIMESURVEY_DIR_MODE}" "${PLUGINS_DIR}/${zip_file_name}"
}

pushd "${PLUGINS_DIR}"

if [[ "${SIMVA_LIMESURVEY_PLUGIN_LOCAL_DEPLOYMENT}" == "true" ]]; then
    echo "Local deployment mode enabled for LimeSurvey plugins."
    SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH=$(validate_local_path "${SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH}" "SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH")
fi

for key in "${!plugins[@]}"; do
    ext_name=$key
    ext_version=${plugins[$key]}
    echo "Key: $ext_name, Value: $ext_version"
    ext_zip="$ext_name-${ext_version}.zip"

    if [[ "${SIMVA_LIMESURVEY_PLUGIN_LOCAL_DEPLOYMENT}" == "true" ]]; then
        # Each plugin is built from its own local folder named as the plugin.
        # Example: ${SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH}/LimeSurveyWebhook
        local_plugin_dir="${SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH}/${ext_name}"
        build_local_plugin_zip "${local_plugin_dir}" "${ext_name}" "${ext_version}" "${ext_zip}"
    else
        GIT_RELEASE_URL="https://github.com/e-ucm/$ext_name/releases/download/v${ext_version}"
        shasums="SHA256SUMS-$ext_name-${ext_version}"
        wget -q -O "${PLUGINS_DIR}/${shasums}" "${GIT_RELEASE_URL}/SHA256SUMS"
        if [[ -f "${PLUGINS_DIR}/${ext_zip}" ]]; then
            echo "Plugin ${ext_zip} already downloaded."
            echo "Verifying checksum..."
            set +e
            echo "$(cat "${PLUGINS_DIR}/${shasums}"  | grep "${ext_zip}" | cut -d' ' -f1) ${ext_zip}" | sha256sum -c -w -
            res=$?
            set -e
            if [[ $res -eq 0 ]]; then
                echo "Checksum valid."
            else
                echo "Checksum invalid. Re-downloading ${ext_zip}..."
                rm -f "${PLUGINS_DIR}/${ext_zip}"
            fi
        fi
        if [[ ! -f "${PLUGINS_DIR}/${ext_zip}" ]]; then
            wget -q -P "${PLUGINS_DIR}" "${GIT_RELEASE_URL}/${ext_zip}"
            chmod -R "${SIMVA_LIMESURVEY_DIR_MODE}" "${PLUGINS_DIR}/${ext_zip}"
            echo "$(cat "${PLUGINS_DIR}/${shasums}"  | grep "${ext_zip}" | cut -d' ' -f1) ${ext_zip}" | sha256sum -c -w -
        fi
    fi

    tmp_dir=$(mktemp -d)
    unzip "${PLUGINS_DIR}/${ext_zip}" -d "${tmp_dir}"
    rsync -avh --delete --itemize-changes "${tmp_dir}/" "${DEPLOYMENT_DIR}/${ext_name}"
    chown -R "${SIMVA_LIMESURVEY_GUID}:${SIMVA_LIMESURVEY_UUID}" "${DEPLOYMENT_DIR}/${ext_name}"
done
popd