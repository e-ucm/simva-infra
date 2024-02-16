#!/bin/bash

$minioPoliciesFolder="${SIMVA_CONFIG_HOME}/minio/policies"
for path in "$minioPoliciesFolder-template/*" do echo $filename done
    config_contents=$(<"$path")    
    base_name=$(basename ${filename})
    echo "${config_contents}" \
        | sed  "s/<<SIMVA_TRACES_BUCKET_NAME>>/${SIMVA_TRACES_BUCKET_NAME}/g" \
        | sed  "s/<<SIMVA_SINK_TOPICS_DIR>>/${SIMVA_SINK_TOPICS_DIR}/g" \
        | sed  "s/<<SIMVA_TRACES_TOPIC>>/${SIMVA_TRACES_TOPIC}/g" \
        | sed  "s/<<SIMVA_SINK_USERS_DIR>>/${SIMVA_SINK_USERS_DIR}/g" \
        > "${minioPoliciesFolder}/${base_name}"
end