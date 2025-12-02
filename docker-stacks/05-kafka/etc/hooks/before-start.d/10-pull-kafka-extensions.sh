#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

EXTENSIONS_DIR="${SIMVA_DATA_HOME}/kafka/connect/extensions"
if [[ ! -d "${EXTENSIONS_DIR}" ]]; then
    mkdir "${EXTENSIONS_DIR}"
fi

DEPLOYMENT_DIR="${SIMVA_DATA_HOME}/kafka/connect/kafka-connect-storage-common/"
if [[ ${SIMVA_KAFKA_VERSION%%.*} -ge 7 ]]; then
    # (tested in KAFKA 7.8.0)
    SIMVA_EXTENSIONS="es.e-ucm.simva.kafka.simva-kafka-connect-json-partitioner es.e-ucm.simva.kafka.simva-kafka-connect-json-format"
    KAFKA_VERSION="kafka7"
else
    # (tested in KAFKA 5.5.0)
    SIMVA_EXTENSIONS="es.e-ucm.simva.kafka.simva-kafka-connect-json-partitioner"
    KAFKA_VERSION="kafka5"
fi

pushd "${EXTENSIONS_DIR}"
GIT_RELEASE_URL="https://github.com/e-ucm/kafka-extensions/releases/download/v${SIMVA_KAFKA_EXTENSIONS_VERSION}"
for ext in $SIMVA_EXTENSIONS; do
    ext_jar="${ext}-${KAFKA_VERSION}-${SIMVA_KAFKA_EXTENSIONS_VERSION}.jar"
    if [[ ! -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
        wget -q -P "${EXTENSIONS_DIR}" "${GIT_RELEASE_URL}/${ext_jar}"
        chmod -R ${SIMVA_KAKFKA_DIR_MODE} "${EXTENSIONS_DIR}/${ext_jar}"
        shasums="SHA256SUMS-KAFKA-EXTENSIONS-${SIMVA_KAFKA_EXTENSIONS_VERSION}"
        if [[ ! -f "${EXTENSIONS_DIR}/${shasums}" ]]; then
            wget -q -O "${EXTENSIONS_DIR}/${shasums}" "${GIT_RELEASE_URL}/SHA256SUMS"
        fi
        echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -
        cp "${EXTENSIONS_DIR}/${ext_jar}" "${DEPLOYMENT_DIR}/${ext}.jar"
    fi
done
popd