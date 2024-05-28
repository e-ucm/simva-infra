#!/usr/bin/env bash
#set -euo pipefail
#[[ "${DEBUG:-false}" == "true" ]] && set -x
#
#if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then
#    # Data deployment folder
#    extension=${SIMVA_DATA_HOME}/keycloak/deployments
#
#    ## QUARKUS quarkus-rest-client-reactive ####
#    GROUPID="io/quarkus"
#    ARTIFACTID=quarkus-rest-client-reactive
#    VERSION=${SIMVA_QUARKUS_VERSION:-3.9.0.CR2}
#
#    URL="https://repo1.maven.org/maven2/${GROUPID}/${ARTIFACTID}/${VERSION}"
#    fileName=${ARTIFACTID}-${VERSION}.jar
#    jarFilePath=${extension}/${ARTIFACTID}.jar
#
#    if [[ ! -e "${jarFilePath}" ]]; then 
#        curl "${URL}/${fileName}" --output "${jarFilePath}"
#    fi
#
#    ## QUARKUS quarkus-jaxrs-client-reactive ####
#    GROUPID="io/quarkus"
#    ARTIFACTID=quarkus-jaxrs-client-reactive
#
#    URL="https://repo1.maven.org/maven2/${GROUPID}/${ARTIFACTID}/${VERSION}"
#    fileName=${ARTIFACTID}-${VERSION}.jar
#    jarFilePath=${extension}/${ARTIFACTID}.jar
#
#    if [[ ! -e "${jarFilePath}" ]]; then 
#        curl "${URL}/${fileName}" --output "${jarFilePath}"
#    fi
#
#    ## QUARKUS quarkus-rest-client-reactive ####
#    GROUPID="io/quarkus"
#    ARTIFACTID=quarkus-resteasy-reactive-jackson
#
#    URL="https://repo1.maven.org/maven2/${GROUPID}/${ARTIFACTID}/${VERSION}"
#    fileName=${ARTIFACTID}-${VERSION}.jar
#    jarFilePath=${extension}/${ARTIFACTID}.jar
#
#    if [[ ! -e "${jarFilePath}" ]]; then 
#        curl "${URL}/${fileName}" --output "${jarFilePath}"
#    fi
#    ## jakarta ###
#    GROUPID="jakarta/ws/rs"
#    ARTIFACTID=jakarta.ws.rs-api
#    VERSION="3.1.0"
#
#    URL="https://repo1.maven.org/maven2/${GROUPID}/${ARTIFACTID}/${VERSION}"
#    fileName=${ARTIFACTID}-${VERSION}.jar
#    jarFilePath=${extension}/${ARTIFACTID}.jar
#
#    if [[ ! -e "${jarFilePath}" ]]; then 
#        curl "${URL}/${fileName}" --output "${jarFilePath}"
#    fi
#
#    ## resteasy client ###
#    GROUPID="org/jboss/resteasy"
#    ARTIFACTID=resteasy-client
#    VERSION="6.2.7.Final"
#
#    URL="https://repo1.maven.org/maven2/${GROUPID}/${ARTIFACTID}/${VERSION}"
#    fileName=${ARTIFACTID}-${VERSION}.jar
#    jarFilePath=${extension}/${ARTIFACTID}.jar
#
#    if [[ ! -e "${jarFilePath}" ]]; then 
#        curl "${URL}/${fileName}" --output "${jarFilePath}"
#    fi
#fi