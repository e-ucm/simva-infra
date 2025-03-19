#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="keycloak"

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
    if [[ ! -e "${SIMVA_DATA_HOME}/keycloak/.initialized" ]]; then 
        echo "SIMVA is not initialized. Importing realm..." 
        "${SIMVA_HOME}/bin/run-command.sh" /opt/keycloak/bin/kc.sh import --file "/opt/keycloak/data/simva-realm-filled/simva-realm-full.json" --override false --optimized
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
    
    if [[ ! -e "${SIMVA_CONFIG_HOME}/keycloak/.migration" ]]; then 
        source "${STACK_HOME}/etc/hooks/helpers.d/keycloak-functions.sh"
        source "${SIMVA_HOME}/bin/get-or-generate.sh"

        events_activated=$([ "$SIMVA_ENVIRONMENT" == "development" ] && echo "true" || echo "false")

        __update_realm_with_params -s registrationAllowed=${SIMVA_SSO_SELF_REGISTRATION_ALLOWED} \
            -s eventsEnabled=${events_activated} \
            -s adminEventsEnabled=${events_activated} \
            -s adminEventsDetailsEnabled=${events_activated}
        
        __add_or_update_role "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/roles" "/opt/keycloak/data/simva-realm-filled/roles"
        __add_or_update_user "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/users" "/opt/keycloak/data/simva-realm-filled/users"

        __keycloak_login
        # Update users config
        users="student teaching_assistant teacher researcher administrator"
        conf_file="${STACK_CONF}/realm-data.users.yml"
        if [[ -e ${conf_file} ]]; then
            rm -rf ${conf_file}
        fi
        echo "users:" > ${conf_file}
        for user in $users; do
            user=$(echo ${user} | sed -e 's/[^0-9A-Za-z_]/_/g' )
            user_username=$(get_or_generate_username "${user}" "${STACK_CONF}/simva-env.sh" "USER")
            user_password=$(get_or_generate_password "${user}" "${STACK_CONF}/simva-env.sh" "USER")
            cat << EOF >> ${conf_file}
  ${user}:
    username: "${user_username}"
    password: "${user_password}"
EOF
            echo "Setting password for username ${user_username}"
            "${SIMVA_HOME}/bin/run-command.sh" /opt/keycloak/bin/kcadm.sh set-password -r ${SIMVA_SSO_REALM} --username $user_username --new-password $user_password
            echo "Setting password for username ${user_username} done"
        done
        
        __add_or_update_client_scope "${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/clients-scopes/lti" "/opt/keycloak/data/simva-realm/clients-scopes/lti"
        __add_or_update_client_scope "${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/clients-scopes/saml" "/opt/keycloak/data/simva-realm/clients-scopes/saml"
        __add_or_update_client_scope "${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/clients-scopes/policy-role" "/opt/keycloak/data/simva-realm/clients-scopes/policy-role"
        
        __add_or_update_client "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/clients" "/opt/keycloak/data/simva-realm-filled/clients"
    fi
else
    echo "Please upgrade to a newer keycloak version ( > 18.*.*) before importing users and realm."
fi;