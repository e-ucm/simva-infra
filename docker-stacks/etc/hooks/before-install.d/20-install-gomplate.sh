#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

set +e
which gomplate >/dev/null
gomplate_installed=$?
set -e

echo "PATH: $PATH"
if [[ ${gomplate_installed} -ne 0 ]]; then
    GOMPLATE_VERSION=v3.10.0
    #!/bin/bash

    echo ${SIMVA_SYSTEM_OS}-${SIMVA_SYSTEM_ARCHITECTURE}
    # Set the default download URL and SHA256SUMS URL
    GOMPLATE_DOWNLOAD_URL="https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_${SIMVA_SYSTEM_OS}-${SIMVA_SYSTEM_ARCHITECTURE}"
    GOMPLATE_SHA256SUMS_URL="https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/checksums-${GOMPLATE_VERSION}_sha256.txt"
    GOMPLATE_FILE_NAME=$(basename $GOMPLATE_DOWNLOAD_URL)
    # Download gomplate and verify checksum
    curl -sSL "$GOMPLATE_SHA256SUMS_URL" > /tmp/gomplate-sha256sums
    curl -sSL "$GOMPLATE_DOWNLOAD_URL" > /tmp/${GOMPLATE_FILE_NAME}

    # Verify checksum
    cat /tmp/gomplate-sha256sums | grep "${GOMPLATE_FILE_NAME}$" | sed -e 's/bin\//\/tmp\//' | sha256sum -c -

    # Move gomplate to the desired location
    mv /tmp/${GOMPLATE_FILE_NAME} "${SIMVA_PROJECT_DIR}/bin/gomplate"

    chmod 777 ${SIMVA_PROJECT_DIR}/bin/gomplate
fi
