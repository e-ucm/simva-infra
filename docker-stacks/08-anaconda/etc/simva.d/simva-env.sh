if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then
    export COMPOSE_FILE="docker-compose.yml"
fi