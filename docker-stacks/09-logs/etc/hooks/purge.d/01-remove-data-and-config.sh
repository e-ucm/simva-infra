#######################
# REMOVE PORTAINER DATA
#######################
# Removing Portainer data
cd "${SIMVA_DATA_HOME}/logs/portainer" && rm -rf ./*
cd "${SIMVA_CONFIG_HOME}/logs/dozzle-config" && rm -rf ./*
cd "${SIMVA_CONFIG_HOME}/logs/portainer-config" && rm -rf ./*

if [[ -e "${SIMVA_DATA_HOME}/logs/.initialized" ]]; then
    rm "${SIMVA_DATA_HOME}/logs/.initialized"
fi
if [[ -e "${SIMVA_DATA_HOME}/logs/.externaldomain" ]]; then
    rm "${SIMVA_DATA_HOME}/logs/.externaldomain"
fi 
if [[ -e "${SIMVA_DATA_HOME}/logs/.version" ]]; then
    rm "${SIMVA_DATA_HOME}/logs/.version"
fi