# Creating Kafka Connect UI config
echo "nameserver ${SIMVA_KAFKA_DNS_IP:-127.0.0.11}" > "${SIMVA_CONFIG_HOME}/kafka/connect-ui/resolv.conf"
echo "options edns0 ndots:0" >>"${SIMVA_CONFIG_HOME}/kafka/connect-ui/resolv.conf"

# Creating Kafka Schema Registry UI config
echo "nameserver ${SIMVA_KAFKA_DNS_IP:-127.0.0.11}" > "${SIMVA_CONFIG_HOME}/kafka/schema-registry-ui/resolv.conf"
echo "options edns0 ndots:0" >>"${SIMVA_CONFIG_HOME}/kafka/schema-registry-ui/resolv.conf"

# Creating Kafka Topics UI config
echo "nameserver ${SIMVA_KAFKA_DNS_IP:-127.0.0.11}" > "${SIMVA_CONFIG_HOME}/kafka/topics-ui/resolv.conf"
echo "options edns0 ndots:0" >>"${SIMVA_CONFIG_HOME}/kafka/topics-ui/resolv.conf"