#!/usr/bin/env bash
set -euo pipefail
if [[ "${SIMVA_RUSTFS_ENABLE:-false}" == "true" ]]; then
    dockerimage="${SIMVA_RUSTFS_RC_IMAGE}"
    dockerversion="${SIMVA_RUSTFS_RC_VERSION}"
    containercommand="rc"
    url="http://${SIMVA_RUSTFS_HOST_SUBDOMAIN:-rustfs}.${SIMVA_INTERNAL_DOMAIN:-internal.test}:9000"
    accesskey="${SIMVA_RUSTFS_ACCESS_KEY}"
    secretkey="${SIMVA_RUSTFS_SECRET_KEY}"
    name="rustfs"
    addhostcommand="alias set"
    userlistcommand="admin user ls"
    policylistcommand="admin policy ls"
    camount=""
    caenv=""
else 
    containercommand="mc"
    dockerimage="${SIMVA_MINIO_MC_IMAGE}"
    dockerversion="${SIMVA_MINIO_MC_VERSION}"
    url="http://${SIMVA_MINIO_HOST_SUBDOMAIN:-minio}.${SIMVA_INTERNAL_DOMAIN:-internal.test}:9000"
    accesskey="${SIMVA_MINIO_ACCESS_KEY}"
    secretkey="${SIMVA_MINIO_SECRET_KEY}"
    name="minio"
    addhostcommand="config host add"
    userlistcommand="admin user list"
    policylistcommand="admin policy list"
    camount="-v ${SIMVA_TLS_HOME}/ca:/root/.mc/certs/CAs/"
    caenv=""
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
    format=$("${SIMVA_BIN_HOME}/volumectl.sh" exec "minio_data" "/vol" cat "/vol/.minio.sys/format.json")
    format=$(echo $format | jq '.format')
    echo $format
    if [[ $format == '"fs"' ]]; then
        #FS BEFORE UPGRADE
        extra_config=""
        policycreate="${containercommand} --debug admin policy add simva-minio/ simvaSink /policies/kafka-connect-simva-sink.json"
        policyattach="${containercommand} --debug admin policy set simva-minio/ simvaSink user=${SIMVA_KAFKA_CONNECT_SINK_USER}"
    else 
        #XL AFTER UPGRADE
        extra_config=""
        [[ "${SIMVA_RUSTFS_ENABLE:-false}" == "true" ]] || extra_config="--api s3v4"
        policycreate="${containercommand} --debug admin policy create simva-minio/ simvaSink /policies/kafka-connect-simva-sink.json"
        policyattach="${containercommand} --debug admin policy attach simva-minio/ simvaSink --user ${SIMVA_KAFKA_CONNECT_SINK_USER}"
    fi
    code="$(cat <<EOF
${containercommand} ${addhostcommand} simva-minio ${url} ${accesskey} ${secretkey} ${extra_config} &&
${containercommand} ready simva-minio &&
user_list="\$(${containercommand} ${userlistcommand} simva-minio/)" &&
bucket_list="\$(${containercommand} ls simva-minio/)" &&
policy_list="\$(${containercommand} ${policylistcommand} simva-minio/)" &&
case "\$user_list" in
    *"${SIMVA_KAFKA_CONNECT_SINK_USER}"*) : ;;
    *) ${containercommand} --debug admin user add simva-minio ${SIMVA_KAFKA_CONNECT_SINK_USER} ${SIMVA_KAFKA_CONNECT_SINK_SECRET} ;;
esac &&
case "\$policy_list" in
    *"simvaSink"*) echo "Policy simvaSink already exists." ;;
    *) echo "Creating policy simvaSink."; ${policycreate} ;;
esac &&
${policyattach} &&
case "\$bucket_list" in
    *"${SIMVA_TRACES_BUCKET_NAME}"*) echo "Bucket ${SIMVA_TRACES_BUCKET_NAME} already exists." ;;
    *) echo "Creating bucket ${SIMVA_TRACES_BUCKET_NAME}."; ${containercommand} --debug mb --ignore-existing simva-minio/${SIMVA_TRACES_BUCKET_NAME} ;;
esac &&
case "\$bucket_list" in
    *"${SIMVA_BACKUP_BUCKET_NAME}"*) echo "Bucket ${SIMVA_BACKUP_BUCKET_NAME} already exists." ;;
    *) echo "Creating bucket ${SIMVA_BACKUP_BUCKET_NAME}."; ${containercommand} --debug mb --ignore-existing simva-minio/${SIMVA_BACKUP_BUCKET_NAME} ;;
esac
EOF
)"
    docker_args=(--rm --network traefik_services -v ${SIMVA_CONFIG_HOME}/minio/policies:/policies:ro)
    [[ -n "${camount}" ]] && docker_args+=(${camount})
    [[ -n "${caenv}" ]] && docker_args+=(${caenv})
    docker_args+=(--entrypoint /bin/sh "${dockerimage}:${dockerversion}" -c "$code")
    docker run "${docker_args[@]}"
fi