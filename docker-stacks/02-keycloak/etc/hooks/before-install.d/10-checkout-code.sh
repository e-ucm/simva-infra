#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then
    SIMVA_KEYCLOAK_EVENT_GIT_REPO_URL=https://github.com/p2-inc/keycloak-events.git
    SIMVA_KEYCLOAK_EVENT_GIT_REF=${SIMVA_KEYCLOAK_EVENT_GIT_REF:-v0.26}

    # Create source folder
    extension=${STACK_HOME}/extensions/keycloak-events
    mkdir -p ${extension}

    # Checkout code in temp dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch ${SIMVA_KEYCLOAK_EVENT_GIT_REF} ${SIMVA_KEYCLOAK_EVENT_GIT_REPO_URL} ${tmp_dir#} > /dev/null 2>&1;

    # Calculate checksums of pom.xml
    pushd ${tmp_dir} > /dev/null 2>&1
    sha256sum pom.xml > sha256sums
    popd > /dev/null 2>&1

    # Verify checksums of current files
    newSha=$(cat ${tmp_dir}/sha256sums)
    if [ -e "${extension}/sha256sums" ] ; then 
        oldSha=$(cat ${extension}/sha256sums)
    else 
        oldSha=""
    fi
    echo $oldSha
    echo $newSha
    # If checksums do not verify -> reinstall dependencies
    rsync_opts="--exclude target"
    if [[ ! ${newSha} == ${oldSha} ]]; then
        rsync_opts=""
    fi
    echo $rsync_opts

    rsync -avh --delete --itemize-changes ${rsync_opts} ${tmp_dir}/ ${extension} > /dev/null 2>&1

    if [[ -e "${extension}/pom.xml" ]]; then
    #   | sed "s/<keycloak.version>[0-9]\+\.[0-9]\+\.[0-9]\+<\/keycloak.version>/<keycloak.version>KEYCLOAKVERSION<\/keycloak.version>/g" \
        cat "${extension}/pom.xml" \
        | sed -e '/<build>/ a\    <finalName>${project.artifactId}</finalName>' \
        > "${extension}/pom.xml.template"
    fi
fi
chmod -R 777 ${extension}