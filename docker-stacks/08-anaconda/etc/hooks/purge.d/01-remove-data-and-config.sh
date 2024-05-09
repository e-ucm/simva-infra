######################
# REMOVE ANACONDA DATA
######################
# Removing Anaconda Jupyter configuration data
cd "${SIMVA_DATA_HOME}/anaconda/jupyter-config"
rm -rf ./*

# Removing Anaconda notebooks data
cd "${SIMVA_DATA_HOME}/anaconda/notebooks"
rm -rf ./*

# Removing Anaconda packages data
cd "${SIMVA_DATA_HOME}/anaconda/packages"
rm -rf ./*

# Removing Anaconda simva-env data
cd "${SIMVA_DATA_HOME}/anaconda/simva-env"
rm -rf ./*

rm "${STACK_HOME}/.initialized"
rm "${STACK_HOME}/.version"
rm "${STACK_HOME}/.externaldomain"