#####################
# REMOVE KAFKA CONFIG
#####################
# Removing Kafka Connect config
cd "${SIMVA_CONFIG_HOME}/kafka/connect"
(GLOBIGNORE=simva-sink-template.json ; rm -rf *)

# Removing Kafka Connect UI config
cd "${SIMVA_CONFIG_HOME}/kafka/connect-ui"
rm -rf ./*

# Removing Kafka Schema Registry UI config
cd "${SIMVA_CONFIG_HOME}/kafka/schema-registry-ui"
rm -rf ./*

# Removing Kafka Topics UI config
cd "${SIMVA_CONFIG_HOME}/kafka/topics-ui"
rm -rf ./*

###################
# REMOVE KAFKA DATA
###################
# Removing Kafka Connect data
cd "${SIMVA_DATA_HOME}/kafka/connect/kafka-connect-storage-common"
rm -rf ./*

# Removing Kafka Backup data
cd "${SIMVA_DATA_HOME}/kafka/data/backup"
rm -rf ./*

# Removing Kafka data
cd "${SIMVA_DATA_HOME}/kafka/data/kafka1"
rm -rf ./*

# Removing Kafka Zoo data
cd "${SIMVA_DATA_HOME}/kafka/data/zoo1"
rm -rf ./*

if [[ -e "${STACK_HOME}/.initialized" ]] then
    rm "${STACK_HOME}/.initialized"
fi
if [[ -e "${STACK_HOME}/.externaldomain" ]] then
    rm "${STACK_HOME}/.externaldomain"
fi 
if [[ -e "${STACK_HOME}/.version" ]] then
    rm "${STACK_HOME}/.version"
fi