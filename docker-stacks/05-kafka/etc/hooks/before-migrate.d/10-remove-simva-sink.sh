#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-file-if-exist.sh "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json"

EXTENSIONS_DIR="${STACK_HOME}/extensions/kafka-connect-storage-common"

for extension in $(find ${EXTENSIONS_DIR} -mindepth 1 -maxdepth 1 -type d); do
    extension_name=${extension#"$EXTENSIONS_DIR"}
    ${SIMVA_BIN_HOME}/purge-file-if-exist.sh "${extension}/pom.xml" "${extension}/target${extension_name}.jar"
done

 ${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
      "${SIMVA_DATA_HOME}/kafka/.minio-events-topics-created"

"${SIMVA_HOME}/simva" uninstall $CURRENT_STACK
"${SIMVA_BIN_HOME}/volumectl.sh" delete "kafka_data"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "zoo_data"