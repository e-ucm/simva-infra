${SIMVA_BIN_HOME}/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/kafka/connect/kafka-connect-storage-common"

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/kafka/connect/extensions/SHA256SUMS-KAFKA-EXTENSIONS-${SIMVA_KAFKA_EXTENSIONS_VERSION}"