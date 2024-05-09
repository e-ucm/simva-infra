#######################
# REMOVE PORTAINER DATA
#######################
# Removing Portainer data
cd "${SIMVA_DATA_HOME}/portainer"
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