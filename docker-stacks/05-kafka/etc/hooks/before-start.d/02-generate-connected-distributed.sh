#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

cat << EOF > ${SIMVA_CONFIG_HOME}/kafka/connect-distributed.properties
# Kafka Connect Distributed Worker configuration

# Kafka cluster
bootstrap.servers=kafka1.${SIMVA_INTERNAL_DOMAIN}:19092
group.id=connect-cluster

# Producer client ID
producer.client.id=connect-worker-producer

# Converters
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
key.converter.schemas.enable=true
value.converter.schemas.enable=true

# Internal converters
internal.key.converter=org.apache.kafka.connect.json.JsonConverter
internal.value.converter=org.apache.kafka.connect.json.JsonConverter

# Storage topics
config.storage.topic=connect-configs
config.storage.replication.factor=1
offset.storage.topic=connect-offsets
offset.storage.replication.factor=1
status.storage.topic=connect-status
status.storage.replication.factor=1

# Offsets flush interval
offset.flush.interval.ms=${SIMVA_KAFKA_CONNECT_OFFSET_FLUSH_INTERVAL_MS}

# REST API
listeners=http://0.0.0.0:8083
rest.advertised.host.name=connect.${SIMVA_INTERNAL_DOMAIN}

# Plugin path (only this folder will be scanned)
plugin.path=/usr/share/confluent-hub-components

# Logging
log4j.rootLogger=INFO, stdout
log4j.logger.org.apache.kafka.connect.runtime.rest=WARN
log4j.logger.org.reflections=ERROR
EOF