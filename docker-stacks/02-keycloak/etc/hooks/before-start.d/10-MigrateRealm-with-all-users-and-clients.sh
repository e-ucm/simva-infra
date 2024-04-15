TEMP_JSON_FILE="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export/${SIMVA_SSO_REALM:-simva}-realm-temp.json"
EXPORTED_JSON_FILE="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export/${SIMVA_SSO_REALM:-simva}-realm.json"
EXPORTED_USERS_JSON_FILE="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export/${SIMVA_SSO_REALM:-simva}-users-0.json"
GENERATED_JSON_FILE="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm/simva-realm-full.json"
NEW_FULL_EXPORTED_JSON_FILE="${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export/${SIMVA_SSO_REALM:-simva}-realm-full.json"

#Adding all new clients to generated file
previousUsers=$(jq '.users' "$GENERATED_JSON_FILE")
newUsers=$(jq '.users' "$EXPORTED_USERS_JSON_FILE")

previousUsersFile="/tmp/previousUsers.json"
echo $previousUsers > $previousUsersFile

# Check if each new users's username is not present in the table and add if absent
allNewUsers=$(jq --argjson new_users "$newUsers" '
  . |= (map(.username) as $existingIds |
    $new_users | map(select(.username | IN($existingIds[]) | not)) + .
  )
' "$previousUsersFile")
rm -f $previousUsersFile
echo $(jq --argjson users "$allNewUsers" '.users = $users' $GENERATED_JSON_FILE) > $TEMP_JSON_FILE

#Adding all new clients to generated file
previousClients=$(jq '.clients' "$GENERATED_JSON_FILE")
newClients=$(jq '.clients' "$EXPORTED_JSON_FILE")

previousClientsFile="/tmp/previousClients.json"
echo $previousClients > $previousClientsFile

# Check if each new client's clientId is not present in the table and add if absent
allNewClients=$(jq --argjson new_clients "$newClients" '
  . |= (map(.clientId) as $existingIds |
    $new_clients | map(select(.clientId | IN($existingIds[]) | not)) + .
  )
' "$previousClientsFile")
rm -f $previousClientsFile
echo $(jq --argjson clients "$allNewClients" '.clients = $clients' $TEMP_JSON_FILE) > "$NEW_FULL_EXPORTED_JSON_FILE"
rm -f $TEMP_JSON_FILE