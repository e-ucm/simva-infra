#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

SIMVA_KEYCLOAK_EVENT_GIT_REPO_URL=https://github.com/p2-inc/keycloak-events.git
SIMVA_KEYCLOAK_EVENT_GIT_REF=${SIMVA_KEYCLOAK_EVENT_GIT_REF:-v0.26}

# Create source folder
mkdir -p ${STACK_HOME}/extensions/keycloak-events

# Checkout code in temp dir
tmp_dir=$(mktemp -d)
git clone --depth 1 --branch ${SIMVA_KEYCLOAK_EVENT_GIT_REF} ${SIMVA_KEYCLOAK_EVENT_GIT_REPO_URL} ${tmp_dir#} > /dev/null 2>&1;
rsync -avh --delete --itemize-changes ${tmp_dir}/ ${STACK_HOME}/extensions/keycloak-events > /dev/null 2>&1

#cp "${STACK_HOME}/extensions/keycloak-events-0.3.jar" "${SIMVA_DATA_HOME}/keycloak/deployments"