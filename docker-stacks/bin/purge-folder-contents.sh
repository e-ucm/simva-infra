#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

folders_to_remove=${1:-}

for folder in ${folders_to_remove}; do
  rm -rf "${folder}/*"
done;