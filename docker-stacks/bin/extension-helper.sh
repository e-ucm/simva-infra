#!/usr/bin/env bash
# Helper functions for building and downloading extensions
# Usage: source this file and call the functions

set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Build a local extension and copy to deployment directory
# Arguments:
#   $1 - LOCAL_PATH: Path to the extensions repository
#   $2 - EXT_SHORT_NAME: Short name of the extension (folder name)
#   $3 - EXT_FULL_NAME: Full extension name (e.g., es.e-ucm.simva.keycloak.fullname-attribute-mapper)
#   $4 - EXT_VERSION: Extension version
#   $5 - DEPLOYMENT_DIR: Directory to copy the built JAR to
#   $6 - BUILD_ARGS: Arguments to pass to the build script (e.g., "k:26" for keycloak or "-k 7.8.0" for kafka)
build_local_extension() {
    local LOCAL_PATH="$1"
    local EXT_SHORT_NAME="$2"
    local EXT_FULL_NAME="$3"
    local EXT_VERSION="$4"
    local DEPLOYMENT_DIR="$5"
    shift 5
    local BUILD_ARGS=("$@")
    
    local ext_jar="${EXT_FULL_NAME}-${EXT_VERSION}.jar"
    local local_jar_path="${LOCAL_PATH}/${EXT_SHORT_NAME}/target/${ext_jar}"
    
    # Build the extension using the build script
    echo "Building extension ${EXT_SHORT_NAME}..."
    pushd "${LOCAL_PATH}" > /dev/null
    ./scripts/build.sh "./${EXT_SHORT_NAME}/" "${BUILD_ARGS[@]}"
    popd > /dev/null
    
    if [[ -f "${local_jar_path}" ]]; then
        echo "Copying local extension ${ext_jar} from ${local_jar_path}..."
        cp "${local_jar_path}" "${DEPLOYMENT_DIR}/${EXT_FULL_NAME}.jar"
    else
        echo "ERROR: Local extension JAR not found after build: ${local_jar_path}"
        return 1
    fi
}

# Download an extension from GitHub and copy to deployment directory
# Arguments:
#   $1 - EXTENSIONS_DIR: Directory to store downloaded extensions
#   $2 - DEPLOYMENT_DIR: Directory to copy the JAR to
#   $3 - GIT_RELEASE_URL: GitHub release URL
#   $4 - SHASUMS_FILE: Name of the SHA256SUMS file
#   $5 - EXT_FULL_NAME: Full extension name
#   $6 - EXT_JAR: JAR filename to download
download_extension() {
    local EXTENSIONS_DIR="$1"
    local DEPLOYMENT_DIR="$2"
    local GIT_RELEASE_URL="$3"
    local SHASUMS_FILE="$4"
    local EXT_FULL_NAME="$5"
    local EXT_JAR="$6"
    
    pushd "${EXTENSIONS_DIR}" > /dev/null
    
    if [[ -f "${EXTENSIONS_DIR}/${EXT_JAR}" ]]; then
        echo "Extension ${EXT_JAR} already downloaded."
        echo "Verifying checksum..."
        set +e
        echo "$(cat "${EXTENSIONS_DIR}/${SHASUMS_FILE}" | grep "${EXT_JAR}" | cut -d' ' -f1) ${EXT_JAR}" | sha256sum -c -w -
        res=$?
        set -e
        if [[ $res -eq 0 ]]; then
            echo "Checksum valid."
            cp "${EXTENSIONS_DIR}/${EXT_JAR}" "${DEPLOYMENT_DIR}/${EXT_FULL_NAME}.jar"
            popd > /dev/null
            return 0
        else
            echo "Checksum invalid. Re-downloading ${EXT_JAR}..."
            rm -f "${EXTENSIONS_DIR}/${EXT_JAR}"
        fi
    fi
    
    if [[ ! -f "${EXTENSIONS_DIR}/${EXT_JAR}" ]]; then
        echo "Downloading extension ${EXT_JAR}..."
        wget -q -P "${EXTENSIONS_DIR}" "${GIT_RELEASE_URL}/${EXT_JAR}"
        echo "$(cat "${EXTENSIONS_DIR}/${SHASUMS_FILE}" | grep "${EXT_JAR}" | cut -d' ' -f1) ${EXT_JAR}" | sha256sum -c -w -
    fi
    cp "${EXTENSIONS_DIR}/${EXT_JAR}" "${DEPLOYMENT_DIR}/${EXT_FULL_NAME}.jar"
    
    popd > /dev/null
}

# Download SHA256SUMS file from GitHub
# Arguments:
#   $1 - EXTENSIONS_DIR: Directory to store the file
#   $2 - GIT_RELEASE_URL: GitHub release URL
#   $3 - SHASUMS_FILE: Local name for the file
download_shasums() {
    local EXTENSIONS_DIR="$1"
    local GIT_RELEASE_URL="$2"
    local SHASUMS_FILE="$3"
    
    wget -q -O "${EXTENSIONS_DIR}/${SHASUMS_FILE}" "${GIT_RELEASE_URL}/SHA256SUMS"
}

# Validate local deployment configuration
# Arguments:
#   $1 - LOCAL_PATH: Path to validate
#   $2 - PATH_VAR_NAME: Name of the environment variable (for error messages)
validate_local_path() {
    local LOCAL_PATH="$1"
    local PATH_VAR_NAME="$2"
    
    if [[ -z "${LOCAL_PATH}" ]]; then
        echo "ERROR: ${PATH_VAR_NAME} is not set."
        return 1
    fi
    
    LOCAL_PATH=$(realpath "${LOCAL_PATH}")
    
    if [[ ! -d "${LOCAL_PATH}" ]]; then
        echo "ERROR: Local extensions path does not exist: ${LOCAL_PATH}"
        return 1
    fi
    
    echo "${LOCAL_PATH}"
}

# Create directory if it doesn't exist
# Arguments:
#   $1 - DIR: Directory path
ensure_dir() {
    local DIR="$1"
    if [[ ! -d "${DIR}" ]]; then
        mkdir -p "${DIR}"
    fi
}
