#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

KEYCLOAK_CONFIG_FOLDER="${SIMVA_CONFIG_HOME}/keycloak/simva-realm"
GENERATED_JSON_FILE="${KEYCLOAK_CONFIG_FOLDER}/simva-realm-full.json"
KEYCLOAK_CONFIG_EXPORT_FOLDER="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export"
EXPORTED_JSON_FILE="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/${SIMVA_SSO_REALM}-realm.json"
TEMP_EXPORTED_JSON_FILE="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/${SIMVA_SSO_REALM}-realm-temp.json"
# Path where JSON clients are stored
CLIENTS_FOLDER="${SIMVA_CONFIG_HOME}/keycloak/simva-realm/clients"
if [[ -e $EXPORTED_JSON_FILE ]]; then
    groups=$(jq '.groups'  $EXPORTED_JSON_FILE)
    jq ". * {groups: $groups}" $GENERATED_JSON_FILE > $TEMP_EXPORTED_JSON_FILE

    # Read existing (already generated) clients
    previousClients=$(jq '.clients' "$GENERATED_JSON_FILE")

    # Load all new clients: merge all json files inside SIMVA folder
    newClients=$(jq -s '.' "$CLIENTS_FOLDER"/*.json | jq '. // []')
    newClientsFile="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/newClients.json"
    echo "$newClients" > "$newClientsFile"
    echo "Loaded new clients count: $(echo "$newClients" | jq 'length')"

    # Store previous clients temporarily
    previousClientsFile="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/previousClients.json"
    echo "$previousClients" > "$previousClientsFile"

    # Filtering new clients:
    # 1) Compare .id, if same -> skip
    # 2) If id different, compare .clientId (name), if same -> skip
    allNewClients=$(jq --argjson new_clients "$newClients" '
        . as $previous |
        ($previous | map({id, clientId})) as $existing |
        $new_clients |
        map(
            select(
                .id as $nid |
                .clientId as $ncid |
                # Keep only clients where neither ID nor clientId match
                ($existing | any(.id == $nid or .clientId == $ncid) | not)
            )
        )
    ' "$previousClientsFile")

    # Append filtered new clients to previous ones
    allClients=$(jq --argjson clients "$allNewClients" '
        . + $clients
    ' "$previousClientsFile")

    # Write back into generated export file
    echo $(jq --argjson clients "$allClients" '.clients = $clients' "$TEMP_EXPORTED_JSON_FILE") > "$TEMP_EXPORTED_JSON_FILE"

    #Adding all new clients role to generated file
    clientsIdAdded=$(echo $allNewClients | jq -r '[.[].clientId]')
    newClientsRole=$(jq '.roles.client' "$EXPORTED_JSON_FILE" )
    
    newClientsRoleFile="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/newclientRole.json"
    echo $newClientsRole > $newClientsRoleFile
    selected_roles=$(jq --argjson clients "$clientsIdAdded" 'to_entries | 
          map(select(.key | IN($clients[]))) | from_entries
          ' $newClientsRoleFile)

    echo $(jq --argjson selected_roles "$selected_roles" '.roles.client=.roles.client + $selected_roles' $TEMP_EXPORTED_JSON_FILE)  > "$TEMP_EXPORTED_JSON_FILE"
    mv $TEMP_EXPORTED_JSON_FILE $EXPORTED_JSON_FILE
    rm -f "$previousClientsFile"
    rm -f "$newClientsFile"
    rm -f "$newClientsRoleFile"
    touch "${KEYCLOAK_CONFIG_EXPORT_FOLDER}/.migrationinprogress"
fi;
rm -rf "${SIMVA_CONFIG_HOME}/keycloak/.migration"