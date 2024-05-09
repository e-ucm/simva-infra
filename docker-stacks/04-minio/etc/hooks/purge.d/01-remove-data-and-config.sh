###################
# REMOVE MINIO DATA
###################
# Removing Minio data
cd "${SIMVA_DATA_HOME}/minio"
rm -rf ./*

#####################
# REMOVE MINIO CONFIG
#####################
# Removing Minio policies configuration
cd "${SIMVA_CONFIG_HOME}/minio/policies"
rm -rf ./*

rm "${STACK_HOME}/.initialized"
rm "${STACK_HOME}/.version"
rm "${STACK_HOME}/.externaldomain"