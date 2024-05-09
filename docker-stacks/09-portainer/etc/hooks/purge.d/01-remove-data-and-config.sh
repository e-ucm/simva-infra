#######################
# REMOVE PORTAINER DATA
#######################
# Removing Portainer data
cd "${SIMVA_DATA_HOME}/portainer"
rm -rf ./*

rm "${STACK_HOME}/.initialized"