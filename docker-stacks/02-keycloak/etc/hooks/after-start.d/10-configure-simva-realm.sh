#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="keycloak"

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
    if [[ ! -e "${SIMVA_DATA_HOME}/keycloak/.initialized" ]]; then 
        echo "SIMVA is not initialized. Importing realm..." 
        "${SIMVA_HOME}/bin/run-command.sh" /opt/keycloak/bin/kc.sh import --file "/opt/keycloak/data/import/simva-realm-full.json" --override false --optimized
    else
        echo "SIMVA is initialized." 
        migrationinProgressFile="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.migrationinprogress"
        if [[ -e "$migrationinProgressFile" ]]; then
            echo "Migration in progress. Importing realm..."
            realmFile="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/${SIMVA_SSO_REALM}-realm.json" 
            if [[ -e "$realmFile" ]]; then
                "${SIMVA_HOME}/bin/run-command.sh" /opt/keycloak/bin/kc.sh import --dir "/opt/keycloak/data/export/" --override true --optimized
            fi;
            rm -f $migrationinProgressFile
        fi;
    fi;
    
    source "${STACK_HOME}/etc/hooks/helpers.d/keycloak-functions.sh"
    source "${SIMVA_HOME}/bin/get-or-generate.sh"
    __keycloak_login
    # Update users config
    users="student teaching_assistant teacher researcher administrator"
    conf_file="${STACK_CONF}/realm-data.users.yml"
    if [[ -e ${conf_file} ]]; then
        rm -rf ${conf_file}
    fi
    echo "users:" >> ${conf_file}
    for user in $users; do
        user=$(echo ${user} | sed -e 's/[^0-9A-Za-z_]/_/g' )
        user_username=$(get_or_generate_username "${user}" "${STACK_CONF}/simva-env.sh" "USER")
        user_password=$(get_or_generate_password "${user}" "${STACK_CONF}/simva-env.sh" "USER")
        echo "  ${user}:" >> ${conf_file}
        echo "    username: \"${user_username}\"" >> ${conf_file}
        echo "    password: \"${user_password}\"" >> ${conf_file}
        echo "Setting password for username ${user_username}"
        "${SIMVA_HOME}/bin/run-command.sh" /opt/keycloak/bin/kcadm.sh set-password -r ${SIMVA_SSO_REALM} --username $user_username --new-password $user_password
        echo "Setting password for username ${user_username} done"
    done
else
    echo "Please upgrade to a newer keycloak version ( > 18.*.*) before importing users and realm."
fi;