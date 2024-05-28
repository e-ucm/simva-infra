${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/anaconda/jupyter-config" \
    "${SIMVA_DATA_HOME}/anaconda/notebooks" \
    "${SIMVA_DATA_HOME}/anaconda/packages" \
    "${SIMVA_DATA_HOME}/anaconda/simva-env"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/anaconda/.initialized" \
    "${SIMVA_DATA_HOME}/anaconda/.externaldomain" \
    "${SIMVA_DATA_HOME}/anaconda/.version"