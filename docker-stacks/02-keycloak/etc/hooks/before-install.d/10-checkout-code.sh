#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

SIMVA_KEYCLOAK_EVENT_GIT_REPO_URL=https://github.com/p2-inc/keycloak-events.git
SIMVA_KEYCLOAK_EVENT_GIT_REF=${SIMVA_KEYCLOAK_EVENT_GIT_REF:-v0.26}

# Create source folder
extension=${STACK_HOME}/extensions/keycloak-events
mkdir -p ${extension}

# Checkout code in temp dir
tmp_dir=$(mktemp -d)
git clone --depth 1 --branch ${SIMVA_KEYCLOAK_EVENT_GIT_REF} ${SIMVA_KEYCLOAK_EVENT_GIT_REPO_URL} ${tmp_dir#} > /dev/null 2>&1;
rsync -avh --delete --itemize-changes ${tmp_dir}/ ${extension} > /dev/null 2>&1

if [[ -e "${extension}/pom.xml" ]]; then
    cat "${extension}/pom.xml" \
       | sed "s/<keycloak.version>[0-9]\+\.[0-9]\+\.[0-9]\+<\/keycloak.version>/<keycloak.version>KEYCLOAKVERSION<\/keycloak.version>/g" \
       | sed -e '/<build>/ a\    <finalName>${project.artifactId}</finalName>' \
      > "${extension}/pom.xml.template"
fi