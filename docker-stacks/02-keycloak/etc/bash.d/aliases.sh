#!/usr/bin/env bash

function __docker_alias() {
    docker run -it --rm \
        --network ${SIMVA_SERVICE_NETWORK} --dns ${SIMVA_DNS_SERVICE_IP} \
        -u $(id -u ${USER}):$(id -g ${USER}) \
        -e HOME=$1 \
        -v $(pwd):$1 -w $1 \
        "${@:2}"
}

function __docker_alias_entrypoint() {
    docker run -it --rm \
        --network ${SIMVA_SERVICE_NETWORK} --dns ${SIMVA_DNS_SERVICE_IP} \
        -u $(id -u ${USER}):$(id -g ${USER}) \
        -e HOME=$1 \
        -v $(pwd):$1 -w $1 \
        --entrypoint "${2}" \
        "${@:3}"
}

# Disabled to fix KEYCLOAK-14595
#function __docker_alias_keycloak_entrypoint() {
#    docker run -it --rm \
#        --network ${SIMVA_SERVICE_NETWORK} --dns ${SIMVA_DNS_SERVICE_IP} \
#        -u $(id -u ${USER}):$(id -g ${USER}) \
#        -e HOME=$1 \
#        -e KC_OPTS="-Duser.home=$1" \
#        -v $(pwd):$1 -w $1 \
#        --entrypoint "${2}" \
#        "${@:3}"
#}
#Removed in volume Keycloak-admin-cli-${SIMVA_KEYCLOAK_VERSION:-10.0.2}.jar because not necessary
# -v ${SIMVA_DATA_HOME}/keycloak/kcadm/keycloak-admin-cli-${SIMVA_KEYCLOAK_VERSION:-10.0.2}.jar:/opt/jboss/keycloak/bin/client/keycloak-admin-cli-${SIMVA_KEYCLOAK_VERSION:-10.0.2}.jar \
# Fixes KEYCLOAK-14595
function __docker_alias_keycloak_entrypoint() {
    docker run -it --rm \
        --network ${SIMVA_SERVICE_NETWORK} --dns ${SIMVA_DNS_SERVICE_IP} \
        -u $(id -u ${USER}):$(id -g ${USER}) \
        -e HOME=$1 \
        -e KC_OPTS="-Duser.home=$1" \
        -v $(pwd):$1 -w $1 \
        -v ${SIMVA_DATA_HOME}/keycloak/kcadm/:/opt/jboss/keycloak/bin/client/ \
        --entrypoint "${2}" \
        "${@:3}"
}

alias kcadm="__docker_alias_keycloak_entrypoint $PWD '/bin/sh' ${SIMVA_KEYCLOAK_IMAGE}:${SIMVA_KEYCLOAK_VERSION} -c '/opt/jboss/keycloak/bin/kcadm.sh \"\$@\"' --"
alias keytool="__docker_alias_entrypoint $PWD '/bin/sh' ${SIMVA_KEYCLOAK_IMAGE}:${SIMVA_KEYCLOAK_VERSION} -c '/usr/bin/keytool \"\$@\"' --"