#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

EXTENSIONS_DIR="${STACK_HOME}/extensions/kafka-connect-storage-common"

for extension in $(find ${EXTENSIONS_DIR} -mindepth 1 -maxdepth 1 -type d); do
    extension_name=${extension#"$EXTENSIONS_DIR"}
    if [[ ! -e "${extension}/target${extension_name}.jar" ]]; then
        if [[ ! -e "${extension}/pom.xml" ]]; then 
            if [[ "${SIMVA_KAFKA_VERSION%%.*}" -ge 7 ]]; then # "7.8.0"
                cp "${extension}/pom-7.8.0.xml" "${extension}/pom.xml"
            else 
                cp "${extension}/pom-5.5.0.xml" "${extension}/pom.xml"
            fi
        fi
        docker run --rm --name maven-project-builder \
            -v $extension:/usr/src/mymaven -w /usr/src/mymaven \
            -v ${SIMVA_DATA_HOME}/maven/m2:/usr/src/mymaven/.m2 \
            -u $(id -u ${USER}):$(id -g ${USER}) \
            -e MAVEN_CONFIG=/usr/src/mymaven/.m2 \
            maven:3.6.3-jdk-8-slim mvn -Duser.home=/usr/src/mymaven clean package
    fi
    cp "${extension}/target${extension_name}.jar" "${SIMVA_DATA_HOME}/kafka/connect/kafka-connect-storage-common"
done
