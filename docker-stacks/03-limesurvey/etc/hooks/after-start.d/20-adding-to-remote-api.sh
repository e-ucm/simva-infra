#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/.initializedRemoteControl" ]]; then 
    export RUN_IN_CONTAINER=true
    export RUN_IN_CONTAINER_NAME="limesurvey"
    # Path to the file inside the container where we want to add the function
    REMOTE_FILE_PATH="/var/www/html/application/helpers/remotecontrol/remotecontrol_handle.php"

    # Path to the file with the new function (local path on the host)
    NEW_FUNCTION_FILE_NAME="export_survey_structure.php"

    # Step 1: Remove the last closing brace '}' from the target file inside the container
    "${SIMVA_HOME}/bin/run-command.sh" bash -c  "sed -i '\$s/^[[:space:]]*}//; \$d' $REMOTE_FILE_PATH"

    # Step 2: Copy the file containing the new function to the container
    docker compose cp $STACK_HOME/patch/$NEW_FUNCTION_FILE_NAME $RUN_IN_CONTAINER_NAME:/tmp/

    # Step 3: Append the new function from the copied file to the target file inside the container
    "${SIMVA_HOME}/bin/run-command.sh" bash -c "cat /tmp/$NEW_FUNCTION_FILE_NAME >> $REMOTE_FILE_PATH"

    # Step 4: Add the closing brace back at the end of the file
    "${SIMVA_HOME}/bin/run-command.sh" bash -c "echo '}' >> $REMOTE_FILE_PATH"

    # Step 5: Optional - Restart the Docker container if necessary
    docker compose restart $RUN_IN_CONTAINER_NAME
    ${SIMVA_HOME}/bin/wait-available.sh "Limesurvey" "https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/admin/authentication/sa/login" "true" "false";

    echo "New function added to the file and container restarted (if applicable)."
    touch "${SIMVA_DATA_HOME}/limesurvey/.initializedRemoteControl"
fi