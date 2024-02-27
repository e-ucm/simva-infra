#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

EXTENSIONS_DIR="${STACK_HOME}/extensions"
simvaURL="${SIMVA_EXTERNAL_PROTOCOL}://${SIMVA_EXTERNAL_DOMAIN}/"
cat "${EXTENSIONS_DIR}/simva-theme/src/main/resources/theme/simva/account/theme.properties.template" \
     | sed  "s|logoUrl=<<SIMVA_SIMVA_URL>>|logoUrl=${simvaURL}|" \
> "${EXTENSIONS_DIR}/simva-theme/src/main/resources/theme/simva/account/theme.properties"

for extension in $(find ${EXTENSIONS_DIR} -mindepth 1 -maxdepth 1 -type d); do
    extension_name=${extension#"$EXTENSIONS_DIR"}
    if [[ ! -e "${extension}/target${extension_name}.jar" ]]; then
        docker run -it --rm --name maven-project-builder \
            -v $extension:/usr/src/mymaven -w /usr/src/mymaven \
            -v ${SIMVA_DATA_HOME}/maven/m2:/usr/src/mymaven/.m2 \
            -u $(id -u ${USER}):$(id -g ${USER}) \
            -e MAVEN_CONFIG=/usr/src/mymaven/.m2 \
            maven:3.6.3-jdk-8-slim mvn -Duser.home=/usr/src/mymaven clean package
    fi
    cp "${extension}/target${extension_name}.jar" "${SIMVA_DATA_HOME}/keycloak/deployments"
done
chmod a+r ${SIMVA_DATA_HOME}/keycloak/deployments
chmod a+w ${SIMVA_DATA_HOME}/keycloak/deployments
chmod a+x ${SIMVA_DATA_HOME}/keycloak/deployments
