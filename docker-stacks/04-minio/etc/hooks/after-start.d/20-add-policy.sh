#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x
if [[ -e "$SIMVA_DATA_HOME/minio/.migration-in-progress-fs-to-xl" ]]; then
    if [ ! -e "${SIMVA_DATA_HOME}/minio/.minio-migrated" ]; then
        docker run --rm \
                    --network traefik_services \
                    -v ${SIMVA_CONFIG_HOME}/minio/policies:/policies:ro \
                    -v ${SIMVA_TLS_HOME}/ca:/root/.mc/certs/CAs/ \
                    --entrypoint /bin/sh \ 
                    ${SIMVA_MINIO_MC_IMAGE}:${SIMVA_MINIO_MC_VERSION} \
                    -c "mc config host add simva-minio "https://${SIMVA_MINIO_API_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" ${SIMVA_MINIO_ACCESS_KEY} ${SIMVA_MINIO_SECRET_KEY} &&
                        mc ready simva-minio &&
                        mc config host add simva-minio-mig "http://${SIMVA_MINIO_HOST_SUBDOMAIN}-mig.${SIMVA_INTERNAL_DOMAIN}:9000" ${SIMVA_MINIO_ACCESS_KEY} ${SIMVA_MINIO_SECRET_KEY} &&
                        mc ready simva-minio-mig &&
                        mc mirror simva-minio-mig/${SIMVA_TRACES_BUCKET_NAME} simva-minio/${SIMVA_TRACES_BUCKET_NAME}"
        format=$(${SIMVA_HOME}/bin/volumectl.sh exec "minio_data" "/vol" cat "/vol/.minio.sys/format.json")
        format=$(echo $format | jq '.format')
        echo $format
        touch "${SIMVA_DATA_HOME}/minio/.minio-migrated";
    fi
else
    if [ ! -e "${SIMVA_DATA_HOME}/minio/.minio-initialized" ]; then
        format=$(${SIMVA_HOME}/bin/volumectl.sh exec "minio_data" "/vol" cat "/vol/.minio.sys/format.json")
        format=$(echo $format | jq '.format')
        echo $format
        if [[ $format == '"fs"' ]]; then
            #FS BEFORE UPGRADE
            minio_url="https://${SIMVA_MINIO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/"
            extra_config=""
            code="mc --debug admin user add simva-minio ${SIMVA_KAFKA_CONNECT_SINK_USER} ${SIMVA_KAFKA_CONNECT_SINK_SECRET} &&
                mc --debug admin policy add simva-minio/ simvaSink /policies/kafka-connect-simva-sink.json &&
                mc --debug admin policy set simva-minio/ simvaSink user=${SIMVA_KAFKA_CONNECT_SINK_USER}"
        else 
            #XL AFTER UPGRADE
            minio_url="https://${SIMVA_MINIO_API_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/"
            extra_config="--api s3v4"
            code="mc --debug admin user add simva-minio ${SIMVA_KAFKA_CONNECT_SINK_USER} ${SIMVA_KAFKA_CONNECT_SINK_SECRET} &&
                mc --debug admin policy create simva-minio/ simvaSink /policies/kafka-connect-simva-sink.json &&
                mc --debug admin policy attach simva-minio/ simvaSink --user ${SIMVA_KAFKA_CONNECT_SINK_USER}"
        fi
        docker run --rm \
                --network traefik_services \
                -v ${SIMVA_CONFIG_HOME}/minio/policies:/policies:ro \
                -v ${SIMVA_TLS_HOME}/ca:/root/.mc/certs/CAs/ \
                --entrypoint /bin/sh \
                ${SIMVA_MINIO_MC_IMAGE}:${SIMVA_MINIO_MC_VERSION} \
                -c "mc config host add simva-minio ${minio_url} ${SIMVA_MINIO_ACCESS_KEY} ${SIMVA_MINIO_SECRET_KEY} ${extra_config} &&
                    mc ready simva-minio &&
                    $code &&
                    mc --debug mb simva-minio/${SIMVA_TRACES_BUCKET_NAME}"
        touch "${SIMVA_DATA_HOME}/minio/.minio-initialized";
    fi
fi