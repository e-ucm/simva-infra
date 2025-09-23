#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
  ["${SIMVA_DATA_HOME}/logs/portainer"]="portainer-logs"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    
    "${SIMVA_HOME}/bin/volumectl.sh" migrate "$folder" "$volume"
done

if [[ -d "${SIMVA_DATA_HOME}/logs/portainer" ]]; then 
#  "${SIMVA_HOME}/bin/volumectl.sh" exec "portainer-logs" "/portainer-logs" "
#    # Set ownership recursively
#    chown -R appuser:appuser /portainer-logs;
#
#    # Directories -> 755 (rwxr-xr-x)
#    find /portainer-logs -type d -print0 | xargs -0 chmod 755;
#
#    # Files -> 644 (rw-r--r--)
#    find /portainer-logs -type f -print0 | xargs -0 chmod 644;
#  "
    rm -rf "${SIMVA_DATA_HOME}/logs/portainer"
fi