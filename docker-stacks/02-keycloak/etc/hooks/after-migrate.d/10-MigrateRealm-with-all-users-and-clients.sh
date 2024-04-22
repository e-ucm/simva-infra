GENERATED_JSON_FILE="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm/simva-realm-full.json"
c="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export"
TEMP_JSON_FILE="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/${SIMVA_SSO_REALM:-simva}-realm-temp.json"
EXPORTED_JSON_FILE="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/${SIMVA_SSO_REALM:-simva}-realm.json"
EXPORTED_USERS_JSON_FILE="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/${SIMVA_SSO_REALM:-simva}-users-0.json"
NEW_FULL_EXPORTED_JSON_FILE="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/${SIMVA_SSO_REALM:-simva}-realm-full.json"
if [[ -e $EXPORTED_JSON_FILE ]] && [[ -e $EXPORTED_USERS_JSON_FILE ]]; then 
    cat $GENERATED_JSON_FILE > $TEMP_JSON_FILE

    # Set the realm name or default to "simva" if SIMVA_SSO_REALM is not set
    realm="${SIMVA_SSO_REALM:-simva}"
    
    # Counter for file number
    file_number=0
    # Iterate over files matching the format ${realm}-users-X.json
    for userfile in "${KEYCLOAK_CONFIG_EXPORT_FOLDER}/${realm}-users-"*.json; do
        # Increment the file number
        ((file_number++))
        # Process the file here (replace echo with actual processing)
        echo "Processing file: $userfile"
        echo "File number: $file_number"
        #Adding all new clients to generated file
        previousUsers=$(jq '.users' "$GENERATED_JSON_FILE")
        newUsers=$(jq '.users' "$userfile")

        previousUsersFile="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/previousUsers.json"
        echo $previousUsers > $previousUsersFile

        # Check if each new users's id is not present in the table and add if absent
        allNewUsers=$(jq --argjson new_users "$newUsers" '
          . |= (map(.id) as $existingIds |
            $new_users | map(select(.id | IN($existingIds[]) | not))
          )
        ' "$previousUsersFile")
        rm -f $previousUsersFile
        echo $(jq --argjson users "$allNewUsers" '.users = $users' $userfile) > $userfile
    done

    #Adding all new clients to generated file
    previousClients=$(jq '.clients' "$GENERATED_JSON_FILE")
    newClients=$(jq '.clients' "$EXPORTED_JSON_FILE")

    previousClientsFile="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/previousClients.json"
    echo $previousClients > $previousClientsFile

    # Check if each new client's Id is not present in the table and add if absent
    allNewClients=$(jq --argjson new_clients "$newClients" '
       . |= (map(.id) as $existingIds |
        $new_clients | map(select(.id | IN($existingIds[]) | not))
        )' "$previousClientsFile")
    allClients=$(jq --argjson clients "$allNewClients" '$clients + .' "$previousClientsFile")
    rm -f $previousClientsFile 
    echo $(jq --argjson clients "$allClients" '.clients = $clients' $TEMP_JSON_FILE) > $TEMP_JSON_FILE

    #Adding all new clients role to generated file
    clientsIdAdded=$(echo $allNewClients | jq -r '[.[].clientId]')
    newClientsRole=$(jq '.roles.client' "$EXPORTED_JSON_FILE" )

    newClientsRoleFile="${KEYCLOAK_CONFIG_EXPORT_FOLDER}/newclientRole.json"
    echo $newClientsRole > $newClientsRoleFile
    selected_roles=$(jq --argjson clients "$clientsIdAdded" 'to_entries | 
          map(select(.key | IN($clients[]))) | from_entries
          ' $newClientsRoleFile)
    rm -f $newClientsRoleFile
    echo $(jq --argjson selected_roles "$selected_roles" '.roles.client=.roles.client + $selected_roles' $TEMP_JSON_FILE)  > "$NEW_FULL_EXPORTED_JSON_FILE"
    rm -f $TEMP_JSON_FILE
    rm -f $EXPORTED_JSON_FILE
    touch "${KEYCLOAK_CONFIG_EXPORT_FOLDER}/.migrationinprogress"
fi;