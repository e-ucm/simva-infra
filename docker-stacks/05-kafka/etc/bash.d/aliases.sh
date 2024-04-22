#!/usr/bin/env bash

function __docker_network_alias() {
#    docker run -it --rm \
#        --network ${SIMVA_SERVICE_NETWORK} --dns ${SIMVA_DNS_SERVICE_IP} \
#        --network ${1} \
#        -u $(id -u ${USER}):$(id -g ${USER}) \
#        -e HOME=$2 \
#        -v $(pwd):$2 -w $2 \
#        "${@:3}"
    container_id=$(docker create -it --rm \
        --network ${SIMVA_SERVICE_NETWORK} \
        --dns ${SIMVA_DNS_SERVICE_IP} \
        -u $(id -u ${USER}):$(id -g ${USER}) \
        -e HOME=$2 \
        -v $(pwd):$2 -w $2 \
        "${3}" \
        "kafkacat" \
        "${@:4}" \
    )
    docker network connect ${1} ${container_id}
    docker start -a -i ${container_id}
}

function __docker_alias_network_entrypoint() {
#    docker run -it --rm \
#        --network ${SIMVA_SERVICE_NETWORK} --dns ${SIMVA_DNS_SERVICE_IP} \
#        --network ${1} \
#        -u $(id -u ${USER}):$(id -g ${USER}) \
#        -e HOME=$2 \
#        -v $(pwd):$2 -w $2 \
#        --entrypoint "${3}" \
#        "${@:4}"

    container_id=$(docker run -it --rm \
        --network ${SIMVA_SERVICE_NETWORK} --dns ${SIMVA_DNS_SERVICE_IP} \
        -u $(id -u ${USER}):$(id -g ${USER}) \
        -e HOME=$2 \
        -v $(pwd):$2 -w $2 \
        --entrypoint "${3}" \
        "${4}" \
        "kafkacat" \
        "${@:5}" \
    )
    docker network connect ${1} ${container_id}
    docker start -a -i ${container_id}
}

alias kafkacat="__docker_network_alias ${SIMVA_KAFKA_NETWORK} $PWD confluentinc/cp-kafkacat:${SIMVA_KAFKA_VERSION}"