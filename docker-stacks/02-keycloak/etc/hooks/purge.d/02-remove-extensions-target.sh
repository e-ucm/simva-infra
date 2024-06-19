#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Removing Extension data
for extension in $(find "${STACK_HOME}/extensions" -mindepth 1 -maxdepth 1 -type d); do
    if [[ -e "${extension}/target" ]]; then
        cd "${extension}/target"
        rm -rf ./*
    fi
done