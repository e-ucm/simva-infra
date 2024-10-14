#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Extract the date part of the version string
VERSION_DATE=$(echo $SIMVA_MINIO_VERSION | cut -d'.' -f2)
# Convert the version date to seconds since the epoch using a specific format
VERSION_EPOCH=$((${VERSION_DATE%%-*}))

# Check if date conversion was successful
if [ -z "$VERSION_EPOCH" ]; then
  exit 1
fi

# Define the cutoff date (2022-01-01T00-00-00Z) and remove 'T' and 'Z'
CUTOFF_DATE="2022-01-01T00:00:00Z"
# Convert the cutoff date to seconds since the epoch
CUTOFF_EPOCH=$((${CUTOFF_DATE%%-*}))

# Check if date conversion was successful
if [ -z "$CUTOFF_EPOCH" ]; then
  exit 1
fi

# Compare the dates
if [ $VERSION_EPOCH -ge $CUTOFF_EPOCH ]; then
  if [[ -e "${SIMVA_DATA_HOME}/minio/migration-in-progress-fs-to-xl" ]]; then
    export COMPOSE_FILE="minio-migration-fs-to-xl.yml"
  else 
    export COMPOSE_FILE="docker-compose-minio-xl-after-2022.yml"
  fi
else
    export COMPOSE_FILE="docker-compose-minio-fs-before-2022.yml"
fi