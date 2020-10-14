#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Fixes https://issues.redhat.com/browse/KEYCLOAK-14595
KEYCLOAK_GIT_REPO_URL=https://github.com/keycloak/keycloak.git
KEYCLOAK_GIT_REF=${SIMVA_KEYCLOAK_VERSION:-10.0.2}

if [[ ! -e "${SIMVA_DATA_HOME}/keycloak/kcadm/keycloak-admin-cli-${KEYCLOAK_GIT_REF}.jar" ]]; then
    keycloak_dir=$(mktemp -d)
    git clone --depth 1 --branch ${KEYCLOAK_GIT_REF} ${KEYCLOAK_GIT_REPO_URL} ${keycloak_dir} > /dev/null 2>&1
    pushd ${keycloak_dir} >/dev/null 2>&1
    patch -p1 <<PATCH
--- keycloak/integration/client-cli/admin-cli/pom.xml   2020-06-30 21:13:04.466200019 +0000
+++ keycloak.fixed/integration/client-cli/admin-cli/pom.xml     2020-06-30 21:14:31.469676196 +0000
@@ -41,6 +41,7 @@
         <dependency>
             <groupId>org.apache.httpcomponents</groupId>
             <artifactId>httpclient</artifactId>
+            <version>4.5.12</version>
         </dependency>

         <dependency>
PATCH

    pushd integration/client-cli/admin-cli >/dev/null 2>&1
    docker run -it --rm --name maven-project-builder \
        -v $PWD:/usr/src/mymaven -w /usr/src/mymaven \
        -v ${SIMVA_DATA_HOME}/maven/m2:/usr/src/mymaven/.m2 \
        -u $(id -u ${USER}):$(id -g ${USER}) \
        -e MAVEN_CONFIG=/usr/src/mymaven/.m2 \
        maven:3.6.3-jdk-8-slim mvn -Duser.home=/usr/src/mymaven clean package

    cp "target/keycloak-admin-cli-${KEYCLOAK_GIT_REF}.jar" "${SIMVA_DATA_HOME}/keycloak/kcadm"
    popd >/dev/null 2>&1
    popd >/dev/null 2>&1
    rm -fr ${keycloak_dir}
fi
