#!/bin/bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_KAFKA_VERSION%%.*}" -ge 7 ]]; then # "7.8.0"
    # Define the paths for cluster ID and storage formatted flag
    CLUSTER_ID_FILE="${SIMVA_DATA_HOME}/kafka/.clusterid"

    # Check if the cluster ID file already exists
    if [ -f "$CLUSTER_ID_FILE" ]; then
        echo "Cluster ID file already exists. Loading existing Cluster ID..."
        export KAFKA_CLUSTER_ID=$(cat "$CLUSTER_ID_FILE")
    else
        meta=$("${SIMVA_BIN_HOME}/volumectl.sh" exec "kafka_data" "/volume_data" "
        if [ -f "/volume_data/meta.properties" ]; then
            cat /volume_data/meta.properties
        else 
            echo ''
        fi");
        if [ "$meta" == "" ]; then
            echo "Generating a new KRaft Cluster ID..."
            CLUSTER_ID=$(docker run --rm ${SIMVA_KAFKA_SERVER_IMAGE:-confluentinc/cp-server}:${SIMVA_KAFKA_VERSION:-7.8.0} kafka-storage random-uuid)
            echo "Generated Cluster ID: $CLUSTER_ID"
        else 
            echo "Extracting KRaft Cluster ID from existing meta.properties..."
            CLUSTER_ID=$(echo "$meta" | grep 'cluster.id=' | cut -d'=' -f2)
            echo "Found existing Cluster ID: $CLUSTER_ID"
        fi
        # Save the Cluster ID to a file for persistence
        echo "$CLUSTER_ID" > "$CLUSTER_ID_FILE"
        export KAFKA_CLUSTER_ID=$(cat "$CLUSTER_ID_FILE")
    fi
    echo "Using KRaft Cluster ID: $KAFKA_CLUSTER_ID"
fi;