#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

mkdir -p ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/simva${SIMVA_STORAGE_LOCAL_PATH:-/storage}