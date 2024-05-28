#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

chmod -R 777 ${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/limesurvey