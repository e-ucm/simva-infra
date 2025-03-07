#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

EXTENSIONS_DIR="${STACK_HOME}/extensions/kafka-connect-storage-common"

for extension in $(find ${EXTENSIONS_DIR} -mindepth 1 -maxdepth 1 -type d); do
    extension_name=es.e-ucm.simva.kafka.${extension#"$EXTENSIONS_DIR/"}
    echo $extension_name
    if [[ ! -e "${extension}/target/${extension_name}-${SIMVA_KAFKA_EXTENSIONS_VERSION}.jar" ]]; then
        customValue=""
        if [[ "${SIMVA_KAFKA_VERSION%%.*}" -ge 7 ]]; then # "7.8.0"
            customValue="-Dkafka.connect.version=${SIMVA_KAFKA_VERSION} -Dkafka.connect-storage-partitioner.version=11.2.16 -Dkafka.connect-api.version=3.9.0 -Dkafka.connect-s3.version=10.2.16"
        else 
            customValue="-Dkafka.connect.version=${SIMVA_KAFKA_VERSION} -Dkafka.connect-storage-partitioner.version=${SIMVA_KAFKA_VERSION} -Dkafka.connect-api.version=3.9.0 -Dkafka.connect-s3.version=${SIMVA_KAFKA_VERSION}"
        fi
        docker run --rm --name maven-project-builder \
            -v $extension:/usr/src/mymaven -w /usr/src/mymaven \
            -v ${SIMVA_DATA_HOME}/maven/m2:/usr/src/mymaven/.m2 \
            -u $(id -u ${USER}):$(id -g ${USER}) \
            -e MAVEN_CONFIG=/usr/src/mymaven/.m2 \
            maven:3.6.3-jdk-8-slim mvn -Duser.home=/usr/src/mymaven $customValue clean package
    fi
    cp "${extension}/target/${extension_name}-${SIMVA_KAFKA_EXTENSIONS_VERSION}.jar" "${SIMVA_DATA_HOME}/kafka/connect/kafka-connect-storage-common/${extension_name}.jar"
done
chmod 777 "${SIMVA_DATA_HOME}/kafka/connect/kafka-connect-storage-common/"