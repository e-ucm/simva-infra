#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

KEYCLOAK_CONFIG_FOLDER="${SIMVA_CONFIG_HOME}/keycloak/simva-realm"
GENERATED_JSON_FILE="${KEYCLOAK_CONFIG_FOLDER}/simva-realm-full.json"
KEYCLOAK_CONFIG_EXPORT_FOLDER="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export"
EXPORTED_JSON_FILE="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/${SIMVA_SSO_REALM}-realm.json"
EXPORTED_USERS_JSON_FILE="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/${SIMVA_SSO_REALM}-users-0.json"
if [[ -e $EXPORTED_JSON_FILE ]] && [[ -e $EXPORTED_USERS_JSON_FILE ]]; then 
    cp $GENERATED_JSON_FILE $EXPORTED_JSON_FILE
    touch "${KEYCLOAK_CONFIG_EXPORT_FOLDER}/.migrationinprogress"
fi;