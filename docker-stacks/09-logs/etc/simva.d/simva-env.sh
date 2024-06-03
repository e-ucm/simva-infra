export COMPOSE_FILE="docker-compose.dozzle.yml"
if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.portainer.yml"    
fi