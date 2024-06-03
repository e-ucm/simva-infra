if [[ -e "${SIMVA_DATA_HOME}/network/.initialized" ]]; then
    rm "${SIMVA_DATA_HOME}/network/.initialized"
fi
if [[ -e "${SIMVA_DATA_HOME}/network/.externaldomain" ]]; then
    rm "${SIMVA_DATA_HOME}/network/.externaldomain"
fi 
if [[ -e "${SIMVA_DATA_HOME}/network/.version" ]]; then
    rm "${SIMVA_DATA_HOME}/network/.version"
fi