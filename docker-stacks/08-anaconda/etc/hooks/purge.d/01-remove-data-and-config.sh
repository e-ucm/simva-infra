######################
# REMOVE ANACONDA DATA
######################
# Removing Anaconda Jupyter configuration data
cd "${SIMVA_DATA_HOME}/anaconda/jupyter-config" && rm -rf ./*

# Removing Anaconda notebooks data
cd "${SIMVA_DATA_HOME}/anaconda/notebooks" && rm -rf ./*

# Removing Anaconda packages data
cd "${SIMVA_DATA_HOME}/anaconda/packages" && rm -rf ./*

# Removing Anaconda simva-env data
cd "${SIMVA_DATA_HOME}/anaconda/simva-env" && rm -rf ./*

if [[ -e "${SIMVA_DATA_HOME}/anaconda/.initialized" ]]; then
    rm "${SIMVA_DATA_HOME}/anaconda/.initialized"
fi
if [[ -e "${SIMVA_DATA_HOME}/anaconda/.externaldomain" ]]; then
    rm "${SIMVA_DATA_HOME}/anaconda/.externaldomain"
fi 
if [[ -e "${SIMVA_DATA_HOME}/anaconda/.version" ]]; then
    rm "${SIMVA_DATA_HOME}/anaconda/.version"
fi