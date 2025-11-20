#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_CONFIG_HOME}/kafka/connect" \
    "${SIMVA_DATA_HOME}/kafka/connect/extensions" \
    "${SIMVA_DATA_HOME}/kafka/connect/kafka-connect-storage-common" \
    "${SIMVA_DATA_HOME}/kafka/data/backup" \
    "${SIMVA_DATA_HOME}/kafka/data/zoo1"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/kafka/.initialized" \
    "${SIMVA_DATA_HOME}/kafka/.externaldomain" \
    "${SIMVA_DATA_HOME}/kafka/.version" \
    "${SIMVA_DATA_HOME}/kafka/storageformatted" \
    "${SIMVA_DATA_HOME}/kafka/.clusterid" \
    "${SIMVA_DATA_HOME}/kafka/.minio-events-topics-created"

"${SIMVA_HOME}/bin/volumectl.sh" delete "kafka_data"