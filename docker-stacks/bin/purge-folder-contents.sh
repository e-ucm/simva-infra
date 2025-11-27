#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

folders_to_remove=$@

for folder in ${folders_to_remove}; do
  if [[ -e "${folder}" ]]; then
    echo "Removing content of folder $folder"
    find "$folder" -mindepth 1 -maxdepth 1 ! -name '.*'  -exec rm -rf {} +
  fi
done;