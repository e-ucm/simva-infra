###################
# REMOVE MINIO DATA
###################
# Removing Minio data
cd "${SIMVA_DATA_HOME}/minio" && rm -rf ./*

#####################
# REMOVE MINIO CONFIG
#####################
# Removing Minio policies configuration
cd "${SIMVA_CONFIG_HOME}/minio/policies" && rm -rf ./*

if [[ -e "${SIMVA_DATA_HOME}/minio/.initialized" ]]; then
    rm "${SIMVA_DATA_HOME}/minio/.initialized"
fi
if [[ -e "${SIMVA_DATA_HOME}/minio/.externaldomain" ]]; then
    rm "${SIMVA_DATA_HOME}/minio/.externaldomain"
fi 
if [[ -e "${SIMVA_DATA_HOME}/minio/.version" ]]; then
    rm "${SIMVA_DATA_HOME}/minio/.version"
fi