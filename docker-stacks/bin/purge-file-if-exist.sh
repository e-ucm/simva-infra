#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

files_to_remove=${1:-}

for file in ${files_to_remove}; do
  if [[ -e "${file}" ]]; then
    rm -f "${file}"
  fi
done;