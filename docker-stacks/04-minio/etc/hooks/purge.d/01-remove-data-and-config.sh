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

if [[ -e "${STACK_HOME}/.initialized" ]]; then
    rm "${STACK_HOME}/.initialized"
fi
if [[ -e "${STACK_HOME}/.externaldomain" ]]; then
    rm "${STACK_HOME}/.externaldomain"
fi 
if [[ -e "${STACK_HOME}/.version" ]]; then
    rm "${STACK_HOME}/.version"
fi