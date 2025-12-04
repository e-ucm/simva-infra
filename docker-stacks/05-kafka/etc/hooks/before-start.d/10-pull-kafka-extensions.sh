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
shasums="SHA256SUMS-KAFKA-EXTENSIONS-${SIMVA_KAFKA_EXTENSIONS_VERSION}"
wget -q -O "${EXTENSIONS_DIR}/${shasums}" "${GIT_RELEASE_URL}/SHA256SUMS"
for ext in $SIMVA_EXTENSIONS; do
    ext_jar="${ext}-${KAFKA_VERSION}-${SIMVA_KAFKA_EXTENSIONS_VERSION}.jar"
    if [[ -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
        echo "Extension ${ext_jar} already downloaded."
        echo "Verifying checksum..."
        set +e
        echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -
        res=$?
        set -e
        if [[ $res -eq 0 ]]; then
            echo "Checksum valid."
            cp "${EXTENSIONS_DIR}/${ext_jar}" "${DEPLOYMENT_DIR}/${ext}.jar"
            continue
        else
            echo "Checksum invalid. Re-downloading ${ext_jar}..."
            rm -f "${EXTENSIONS_DIR}/${ext_jar}"
        fi
    fi
    if [[ ! -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
        echo "Downloading extension ${ext_jar}..."
        wget -q -P ${EXTENSIONS_DIR} "${GIT_RELEASE_URL}/${ext_jar}"
        echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -
    fi
    cp "${EXTENSIONS_DIR}/${ext_jar}" "${DEPLOYMENT_DIR}/${ext}.jar"
done
popd