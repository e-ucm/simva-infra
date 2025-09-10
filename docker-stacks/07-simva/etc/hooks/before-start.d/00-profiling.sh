#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_ENVIRONMENT}" = "production" ]]; then exit 0; fi;

if [[ ${SIMVA_ENABLE_DEBUG_PROFILING} = false ]]; then exit 0; fi;

mkdir -p ${SIMVA_DATA_HOME}/simva/simva-api-profiling-backup
pushd "${SIMVA_DATA_HOME}/simva/simva-api-profiling/"
for file in ${SIMVA_DATA_HOME}/simva/simva-api-profiling/*.html; do
    # Get the file name without the .html extension
    foldername=$(basename "$file" .html)
    # Print the folder name (for debugging purposes)
    echo "Processing : $foldername"
    zip -r ${SIMVA_DATA_HOME}/simva/simva-api-profiling-backup/$foldername.zip ./$foldername ./$foldername.html # Create a zip of the folder
done
popd 

mkdir -p ${SIMVA_DATA_HOME}/simva/simva-front-profiling-backup
pushd "${SIMVA_DATA_HOME}/simva/simva-front-profiling/"
for file in ${SIMVA_DATA_HOME}/simva/simva-front-profiling/*.html; do
# Get the file name without the .html extension
    foldername=$(basename "$file" .html)
    # Print the folder name (for debugging purposes)
    echo "Processing : $foldername"
    zip -r ${SIMVA_DATA_HOME}/simva/simva-front-profiling-backup/$foldername.zip ./$foldername ./$foldername.html # Create a zip of the folder
done
popd 

mkdir -p ${SIMVA_DATA_HOME}/simva/simva-trace-allocator-profiling-backup
pushd "${SIMVA_DATA_HOME}/simva/simva-trace-allocator-profiling/"
for file in ${SIMVA_DATA_HOME}/simva/simva-trace-allocator-profiling/*.html; do
    # Get the file name without the .html extension
    foldername=$(basename "$file" .html)
    # Print the folder name (for debugging purposes)
    echo "Processing : $foldername"
    zip -r ${SIMVA_DATA_HOME}/simva/simva-trace-allocator-profiling-backup/$foldername.zip ./$foldername ./$foldername.html # Create a zip of the folder
done
popd

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    ${SIMVA_DATA_HOME}/simva/simva-api-profiling/ \
    ${SIMVA_DATA_HOME}/simva/simva-front-profiling/ \
    ${SIMVA_DATA_HOME}/simva/simva-trace-allocator-profiling/