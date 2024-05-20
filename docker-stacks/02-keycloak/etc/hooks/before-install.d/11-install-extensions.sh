#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

EXTENSIONS_DIR="${STACK_HOME}/extensions"
DEPLOYMENT_DIR=${SIMVA_DATA_HOME}/keycloak/deployments
if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -gt 18 ]]; then
    mkdir -p $DEPLOYMENT_DIR
    for extension in $(find ${EXTENSIONS_DIR} -mindepth 1 -maxdepth 1 -type d); do
        if [[ -e "${extension}/pom.xml.template" ]]; then
            cat "${extension}/pom.xml.template" \
            | sed  "s|<keycloak.version>KEYCLOAKVERSION</keycloak.version>|<keycloak.version>${SIMVA_KEYCLOAK_VERSION}</keycloak.version>|" \
            > "${extension}/pom.xml"
        fi
        extension_name=${extension#"$EXTENSIONS_DIR"}
        if [[ ! -e "${extension}/target${extension_name}.jar" ]]; then
            docker run --rm --name maven-project-builder \
                -v $extension:/usr/src/mymaven -w /usr/src/mymaven \
                -v ${SIMVA_DATA_HOME}/maven/m2:/usr/src/mymaven/.m2 \
                -u $(id -u ${USER}):$(id -g ${USER}) \
                -e MAVEN_CONFIG=/usr/src/mymaven/.m2 \
                maven:3.8.7-openjdk-18-slim sh -c "apt update && apt install -y git && mvn -Duser.home=/usr/src/mymaven clean package"
        fi
        cp "${extension}/target${extension_name}.jar" $DEPLOYMENT_DIR
    done
    chmod -R 777 DEPLOYMENT_DIR
fi
