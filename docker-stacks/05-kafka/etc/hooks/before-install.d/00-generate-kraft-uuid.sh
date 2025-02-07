#!/bin/bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_KAFKA_VERSION}" == "7.8.0" ]]; then
    # Define the paths for cluster ID and storage formatted flag
    CLUSTER_ID_FILE="${SIMVA_DATA_HOME}/kafka/clusterid"
    STORAGE_FORMATTED_FILE="${SIMVA_DATA_HOME}/kafka/storageformatted"
    LOG_DIR="${SIMVA_DATA_HOME}/kafka/data/kafka1/kraft-combined-logs"

    # Check if storage has already been formatted
    if [ -f "$STORAGE_FORMATTED_FILE" ]; then
        echo "Storage is already formatted. Skipping formatting step."
        export KAFKA_CLUSTER_ID=$(cat "$CLUSTER_ID_FILE")
    else
        # Check if the cluster ID file already exists
        if [ -f "$CLUSTER_ID_FILE" ]; then
            echo "Cluster ID file already exists. Loading existing Cluster ID..."
            export KAFKA_CLUSTER_ID=$(cat "$CLUSTER_ID_FILE")
        else
            echo "Generating a new KRaft Cluster ID..."
            KAFKA_CLUSTER_ID=$(docker run --rm confluentinc/cp-server:7.8.0 kafka-storage random-uuid)
            
            # Save the Cluster ID to a file for persistence
            echo "$KAFKA_CLUSTER_ID" > "$CLUSTER_ID_FILE"
        fi

        #if [ ! -d "$LOG_DIR" ]; then
        #    mkdir "${LOG_DIR}"
        #    chmod -R a+w "${LOG_DIR}"
        #    chmod -R a+r "${LOG_DIR}"
        #fi

        #echo "Formatting storage with Cluster ID..."
        #docker run --rm -v "${SIMVA_CONFIG_HOME}/kafka/kafka1/kraft.properties:/tmp/kafka/kraft.properties" confluentinc/cp-server:7.8.0 \
        #    cat /tmp/kafka/kraft.properties
        #docker run --rm -v "${LOG_DIR}:/tmp/kraft-combined-logs" confluentinc/cp-server:7.8.0 ls -lah /tmp/kraft-combined-logs
        #docker run --rm -v "${LOG_DIR}:/tmp/kraft-combined-logs:rw" -v "${SIMVA_CONFIG_HOME}/kafka/kafka1/kraft.properties:/tmp/kafka/kraft.properties" \
        #    confluentinc/cp-server:7.8.0 \
        #    kafka-storage format --ignore-formatted --cluster-id "$KAFKA_CLUSTER_ID" --config /tmp/kafka/kraft.properties
        #   
        #docker run --rm -v "${LOG_DIR}:/tmp/kraft-combined-logs:rw" -v "${SIMVA_CONFIG_HOME}/kafka/kafka1/kraft.properties:/tmp/kafka/kraft.properties" \
        #    confluentinc/cp-server:7.8.0 \
        #   kafka-storage info --config /tmp/kafka/kraft.properties
        ## Mark storage as formatted
        #touch "$STORAGE_FORMATTED_FILE"
    fi

    echo "Using KRaft Cluster ID: $KAFKA_CLUSTER_ID"
fi;