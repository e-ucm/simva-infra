#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="keycloak"

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
    if [[ ! -e "${SIMVA_DATA_HOME}/keycloak/.initialized" ]]; then 
        echo "SIMVA is not initialized. Importing realm..." 
        "${SIMVA_BIN_HOME}/run-command.sh" /opt/keycloak/bin/kc.sh import --file "/opt/keycloak/data/simva-realm-filled/simva-realm-full.json" --override false --optimized
    else
        echo "SIMVA is initialized." 
        migrationinProgressFile="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.migrationinprogress"
        if [[ -e "$migrationinProgressFile" ]]; then
            echo "Migration in progress. Importing realm..."
            realmFile="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/${SIMVA_SSO_REALM}-realm.json" 
            if [[ -e "$realmFile" ]]; then
                "${SIMVA_BIN_HOME}/run-command.sh" /opt/keycloak/bin/kc.sh import --file /opt/keycloak/data/export/${SIMVA_SSO_REALM}-realm.json --override true --optimized
            fi;
            source "${HELPERS_STACK_HOME}/keycloak-functions.sh"
            __keycloak_login
            __add_or_update_role "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/roles" "/opt/keycloak/data/simva-realm-filled/roles"
            tmp_user_folder="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/tmp"
            if [[ -d "${tmp_user_folder}" ]]; then 
                rm -rf "${tmp_user_folder}"
            fi 
            for f in ${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/${SIMVA_SSO_REALM}-users-*.json; do
                echo "⏳ Importing file $f..."
                mkdir "${tmp_user_folder}"
                while read -r user_json; do
                    user_id=$(echo "$user_json" | jq -r '.id' | sed 's/[^A-Za-z0-9._-]/_/g')
                    user_name=$(echo "$user_json" | jq -r '.username')
                    echo "$user_json" > "$tmp_user_folder/usr-${user_id}.json"
                    echo "User ${user_name} copied into file ${tmp_user_folder}/usr-${user_id}.json"
                done < <(jq -c '.users[]' "$f")
                __add_or_update_user "${tmp_user_folder}" "/opt/keycloak/data/export/tmp"
                tmp_user_folder="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/tmp"
                rm -rf "${tmp_user_folder}"
                echo "File $f Imported !"
            done
            ${SIMVA_BIN_HOME}/purge-file-if-exist.sh $migrationinProgressFile
        fi;
    fi

    if [[ ! -e "${SIMVA_CONFIG_HOME}/keycloak/.migration" ]]; then 
        source "${HELPERS_STACK_HOME}/keycloak-functions.sh"
        source "${SIMVA_BIN_HOME}/get-or-generate.sh"
        __keycloak_login

        events_activated=$([ "$SIMVA_ENVIRONMENT" == "development" ] && echo "true" || echo "false")

        __update_realm_with_params -s registrationAllowed=${SIMVA_SSO_SELF_REGISTRATION_ALLOWED} \
            -s eventsEnabled=${events_activated} \
            -s adminEventsEnabled=${events_activated} \
            -s adminEventsDetailsEnabled=${events_activated}
        
        lang=$(echo "en,$SIMVA_LOCALE" | jq -c -R 'split(",") | unique')
        __update_realm_with_params -s internationalizationEnabled=true \
            -s supportedLocales="$lang" \
            -s defaultLocale=en

        csp="base-uri 'self'; frame-src 'self'; frame-ancestors 'self' https://${SIMVA_EXTERNAL_DOMAIN}; object-src 'none';"
        __update_realm_with_params -s "browserSecurityHeaders.contentSecurityPolicy=$csp"
        
        __keycloak_login
        __add_or_update_role "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/roles" "/opt/keycloak/data/simva-realm-filled/roles"
        __add_or_update_user "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/users" "/opt/keycloak/data/simva-realm-filled/users"

        # Update users config
        users="student teaching_assistant teacher researcher administrator lrsmanager"
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
            "${SIMVA_BIN_HOME}/run-command.sh" /opt/keycloak/bin/kcadm.sh set-password -r ${SIMVA_SSO_REALM} --username $user_username --new-password $user_password
            echo "Setting password for username ${user_username} done"
        done
        
        __add_or_update_client_scope "${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/clients-scopes/openid" "/opt/keycloak/data/simva-realm/clients-scopes/openid"
        __add_or_update_client_scope "${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/clients-scopes/lti" "/opt/keycloak/data/simva-realm/clients-scopes/lti"
        __add_or_update_client_scope "${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/clients-scopes/saml" "/opt/keycloak/data/simva-realm/clients-scopes/saml"
        __add_or_update_client_scope "${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/clients-scopes/policy-role" "/opt/keycloak/data/simva-realm/clients-scopes/policy-role"
        
        __keycloak_login
        __add_or_update_client "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/clients" "/opt/keycloak/data/simva-realm-filled/clients"
    fi
else
    echo "Please upgrade to a newer keycloak version ( > 18.*.*) before importing users and realm."
fi;