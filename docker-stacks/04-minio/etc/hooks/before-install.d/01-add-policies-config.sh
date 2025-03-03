#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

for path in $(ls ${SIMVA_CONFIG_TEMPLATE_HOME}/minio/policies/*) ; do 
    config_contents=$(<"$path")
    base_name=$(basename $path)
    echo "${config_contents}" \
        | sed  "s/<<SIMVA_TRACES_BUCKET_NAME>>/${SIMVA_TRACES_BUCKET_NAME}/g" \
        | sed  "s/<<SIMVA_SINK_TOPICS_DIR>>/${SIMVA_SINK_TOPICS_DIR}/g" \
        | sed  "s/<<SIMVA_TRACES_TOPIC>>/${SIMVA_TRACES_TOPIC}/g" \
        | sed  "s/<<SIMVA_SINK_OUTPUTS_DIR>>/${SIMVA_SINK_OUTPUTS_DIR}/g" \
        > "${SIMVA_CONFIG_HOME}/minio/policies/${base_name}"
done