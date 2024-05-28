#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

files_to_remove=$@

for file in ${files_to_remove}; do
  echo $file
  if [[ -e "${file}" ]]; then
    rm -f "${file}"
  fi
done;