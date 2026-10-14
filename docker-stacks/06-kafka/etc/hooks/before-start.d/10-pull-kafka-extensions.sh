#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Source the extension helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SIMVA_BIN_HOME}/extension-helper.sh"

EXTENSIONS_DIR="${SIMVA_DATA_HOME}/kafka/connect/extensions"
DEPLOYMENT_DIR="${SIMVA_DATA_HOME}/kafka/connect/kafka-connect-storage-common/"
ensure_dir "${EXTENSIONS_DIR}"
ensure_dir "${DEPLOYMENT_DIR}"

if [[ ${SIMVA_KAFKA_VERSION%%.*} -ge 7 ]]; then
    # (tested in KAFKA 7.8.0)
    SIMVA_EXTENSIONS="es.e-ucm.simva.kafka.simva-kafka-connect-json-partitioner es.e-ucm.simva.kafka.simva-kafka-connect-json-format"
    KAFKA_VERSION="kafka7"
else
    # (tested in KAFKA 5.5.0)
    SIMVA_EXTENSIONS="es.e-ucm.simva.kafka.simva-kafka-connect-json-partitioner"
    KAFKA_VERSION="kafka5"
fi

SIMVA_KAFKA_EXTENSION_LOCAL_DEPLOYMENT="${SIMVA_KAFKA_EXTENSION_LOCAL_DEPLOYMENT:-false}"
SIMVA_KAFKA_EXTENSIONS_LOCAL_PATH="${SIMVA_KAFKA_EXTENSIONS_LOCAL_PATH:-}"

if [[ "${SIMVA_KAFKA_EXTENSION_LOCAL_DEPLOYMENT}" == "true" ]]; then
    echo "Local deployment mode enabled for Kafka extensions."
    SIMVA_KAFKA_EXTENSIONS_LOCAL_PATH=$(validate_local_path "${SIMVA_KAFKA_EXTENSIONS_LOCAL_PATH}" "SIMVA_KAFKA_EXTENSIONS_LOCAL_PATH")
    
    for ext in $SIMVA_EXTENSIONS; do
        ext_short_name="${ext##*.}"
        build_local_extension "${SIMVA_KAFKA_EXTENSIONS_LOCAL_PATH}" "${ext_short_name}" "${ext}" \
            "${SIMVA_KAFKA_EXTENSIONS_VERSION}" "${DEPLOYMENT_DIR}" "-k" "${SIMVA_KAFKA_VERSION}"
    done
else
    GIT_RELEASE_URL="https://github.com/e-ucm/kafka-extensions/releases/download/v${SIMVA_KAFKA_EXTENSIONS_VERSION}"
    shasums="SHA256SUMS-KAFKA-EXTENSIONS-${SIMVA_KAFKA_EXTENSIONS_VERSION}"
    download_shasums "${EXTENSIONS_DIR}" "${GIT_RELEASE_URL}" "${shasums}"
    
    for ext in $SIMVA_EXTENSIONS; do
        ext_jar="${ext}-${KAFKA_VERSION}-${SIMVA_KAFKA_EXTENSIONS_VERSION}.jar"
        download_extension "${EXTENSIONS_DIR}" "${DEPLOYMENT_DIR}" "${GIT_RELEASE_URL}" "${shasums}" "${ext}" "${ext_jar}"
    done
fi