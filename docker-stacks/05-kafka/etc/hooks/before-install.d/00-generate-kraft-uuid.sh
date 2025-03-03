#!/bin/bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_KAFKA_VERSION%%.*}" -ge 7 ]]; then # "7.8.0"
    # Define the paths for cluster ID and storage formatted flag
    CLUSTER_ID_FILE="${SIMVA_DATA_HOME}/kafka/clusterid"

    # Check if the cluster ID file already exists
    if [ -f "$CLUSTER_ID_FILE" ]; then
        echo "Cluster ID file already exists. Loading existing Cluster ID..."
        export KAFKA_CLUSTER_ID=$(cat "$CLUSTER_ID_FILE")
    else
        echo "Generating a new KRaft Cluster ID..."
        KAFKA_CLUSTER_ID=$(docker run --rm ${SIMVA_KAFKA_SERVER_IMAGE:-confluentinc/cp-server}:${SIMVA_KAFKA_VERSION:-7.8.0} kafka-storage random-uuid)
        
        # Save the Cluster ID to a file for persistence
        echo "$KAFKA_CLUSTER_ID" > "$CLUSTER_ID_FILE"
    fi

    echo "Using KRaft Cluster ID: $KAFKA_CLUSTER_ID"
fi;

chmod -R 777 ${SIMVA_DATA_HOME}/kafka/data/kafka1/data
chmod -R 777 ${SIMVA_DATA_HOME}/kafka/data/kafka1/kraft-combined-logs