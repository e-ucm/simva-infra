#!/usr/bin/env bash
set -euo pipefail
if [[ "${SIMVA_RUSTFS_ENABLE:-false}" == "true" ]]; then
    dockerimage="${SIMVA_RUSTFS_RC_IMAGE}"
    dockerversion="${SIMVA_RUSTFS_RC_VERSION}"
    containercommand="rc"
    url="https://${SIMVA_RUSTFS_HOST_SUBDOMAIN:-rustfs}.${SIMVA_EXTERNAL_DOMAIN:-external.test}"
    accesskey="${SIMVA_RUSTFS_ACCESS_KEY}"
    secretkey="${SIMVA_RUSTFS_SECRET_KEY}"
else 
    dockerimage="${SIMVA_MINIO_MC_IMAGE}"
    dockerversion="${SIMVA_MINIO_MC_VERSION}"
    containercommand="${containercommand}"
    url="https://${SIMVA_MINIO_HOST_SUBDOMAIN:-minio}.${SIMVA_EXTERNAL_DOMAIN:-external.test}"
    accesskey="${SIMVA_MINIO_ACCESS_KEY}"
    secretkey="${SIMVA_MINIO_SECRET_KEY}"
fi

[[ "${DEBUG:-false}" == "true" ]] && set -x
if [[ -e "$SIMVA_DATA_HOME/minio/.migration-in-progress-fs-to-xl" ]]; then
    if [ ! -e "${SIMVA_DATA_HOME}/minio/.minio-migrated" ]; then
        docker run --rm \
                    --network traefik_services \
                    -v ${SIMVA_CONFIG_HOME}/minio/policies:/policies:ro \
                    -v ${SIMVA_TLS_HOME}/ca:/root/.mc/certs/CAs/ \
                    --entrypoint /bin/sh \
                    ${SIMVA_MINIO_MC_IMAGE}:${SIMVA_MINIO_MC_VERSION} \
                    -c "mc config host add simva-minio "https://${SIMVA_MINIO_API_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" ${accesskey} ${secretkey} &&
                        mc ready simva-minio &&
                        mc config host add simva-minio-mig "http://${SIMVA_MINIO_HOST_SUBDOMAIN}-mig.${SIMVA_INTERNAL_DOMAIN}:9000" ${accesskey} ${secretkey} &&
                        mc ready simva-minio-mig &&
                        mc mirror simva-minio-mig/${SIMVA_TRACES_BUCKET_NAME} simva-minio/${SIMVA_TRACES_BUCKET_NAME}"
        format=$(${SIMVA_BIN_HOME}/volumectl.sh exec "minio_data" "/vol" cat "/vol/.minio.sys/format.json")
        format=$(echo $format | jq '.format')
        echo $format
        touch "${SIMVA_DATA_HOME}/minio/.minio-migrated";
    fi
else
    if [ ! -e "${SIMVA_DATA_HOME}/minio/.minio-initialized" ]; then
        format=$("${SIMVA_BIN_HOME}/volumectl.sh" exec "minio_data" "/vol" cat "/vol/.minio.sys/format.json")
        format=$(echo $format | jq '.format')
        echo $format
        if [[ $format == '"fs"' ]]; then
            #FS BEFORE UPGRADE
            extra_config=""
            code="${containercommand} --debug admin user add simva-minio ${SIMVA_KAFKA_CONNECT_SINK_USER} ${SIMVA_KAFKA_CONNECT_SINK_SECRET} &&
                ${containercommand} --debug admin policy add simva-minio/ simvaSink /policies/kafka-connect-simva-sink.json &&
                ${containercommand} --debug admin policy set simva-minio/ simvaSink user=${SIMVA_KAFKA_CONNECT_SINK_USER}"
        else 
            #XL AFTER UPGRADE
            extra_config="--api s3v4"
            code="${containercommand} admin user info simva-minio ${SIMVA_KAFKA_CONNECT_SINK_USER} >/dev/null 2>&1 || 
                ${containercommand} --debug admin user add simva-minio ${SIMVA_KAFKA_CONNECT_SINK_USER} ${SIMVA_KAFKA_CONNECT_SINK_SECRET} &&
                ${containercommand} --debug admin policy create simva-minio/ simvaSink /policies/kafka-connect-simva-sink.json &&
                ${containercommand} --debug admin policy attach simva-minio/ simvaSink --user ${SIMVA_KAFKA_CONNECT_SINK_USER}"
        fi
        docker run --rm \
                --network traefik_services \
                -v ${SIMVA_CONFIG_HOME}/minio/policies:/policies:ro \
                -v ${SIMVA_TLS_HOME}/ca:/root/.${containercommand}/certs/CAs/ \
                --entrypoint /bin/sh \
                ${SIMVA_MINIO_MC_IMAGE}:${SIMVA_MINIO_MC_VERSION} \
                -c "${containercommand} config host add simva-minio ${url} ${accesskey} ${secretkey} ${extra_config} &&
                    ${containercommand} ready simva-minio &&
                    $code &&
                    ${containercommand} --debug mb --ignore-existing simva-minio/${SIMVA_TRACES_BUCKET_NAME} &&
                    ${containercommand} --debug mb --ignore-existing simva-minio/${SIMVA_BACKUP_BUCKET_NAME}"
        touch "${SIMVA_DATA_HOME}/minio/.minio-initialized";
    fi
fi