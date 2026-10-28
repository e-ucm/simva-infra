#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# The realm export is written by Keycloak itself, so it must live in a Docker volume
# writable by the unprivileged user of the official images (uid 1000, gid 0). This
# avoids running `kc.sh export` as root (which makes the JDBC driver fall back to the
# OS user as database user, failing with "Access denied for user 'root'").
: "${SIMVA_KEYCLOAK_EXPORT_VOLUME:=kc_realm_export_data}"
: "${SIMVA_KEYCLOAK_EXPORT_VOLUME_UID:=1000}"
: "${SIMVA_KEYCLOAK_EXPORT_VOLUME_GID:=0}"
: "${SIMVA_KEYCLOAK_EXPORT_VOLUME_MODE:=0775}"

function __realm_export_volume_prepare() {
    "${SIMVA_BIN_HOME}/volumectl.sh" create "${SIMVA_KEYCLOAK_EXPORT_VOLUME}"
    "${SIMVA_BIN_HOME}/volumectl.sh" execcheck "${SIMVA_KEYCLOAK_EXPORT_VOLUME}" "/volume_data" \
        "chown ${SIMVA_KEYCLOAK_EXPORT_VOLUME_UID}:${SIMVA_KEYCLOAK_EXPORT_VOLUME_GID} /volume_data && chmod ${SIMVA_KEYCLOAK_EXPORT_VOLUME_MODE} /volume_data"
}

function __realm_export_volume_reset() {
    "${SIMVA_BIN_HOME}/volumectl.sh" execcheck "${SIMVA_KEYCLOAK_EXPORT_VOLUME}" "/volume_data" \
        "find /volume_data -mindepth 1 -maxdepth 1 -exec rm -rf {} +"
}

# Copies the content of the export volume into a host directory, giving the files to
# the user running SIMVA so the host-side jq post-processing can rewrite them.
function __realm_export_volume_sync_to_host() {
    local host_dir="$1"
    mkdir -p "${host_dir}"
    docker run --rm \
        -v "${SIMVA_KEYCLOAK_EXPORT_VOLUME}:/src:ro" \
        -v "$(realpath "${host_dir}")":/dest \
        alpine sh -c "cp -a /src/. /dest/ && chown -R $(id -u):$(id -g) /dest"
}
