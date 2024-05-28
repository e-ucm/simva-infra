${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/minio" \
    "${SIMVA_CONFIG_HOME}/minio/policies"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/minio/.initialized" \
    "${SIMVA_DATA_HOME}/minio/.externaldomain" \
    "${SIMVA_DATA_HOME}/minio/.version"