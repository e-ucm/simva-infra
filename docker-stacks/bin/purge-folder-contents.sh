#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

folders_to_remove=$@

for folder in ${folders_to_remove}; do
  echo "Removing content of folder $folder"
  find "$folder" -mindepth 1 -maxdepth 1 ! -name '.gitignore'  -exec rm -rf {} +
done;