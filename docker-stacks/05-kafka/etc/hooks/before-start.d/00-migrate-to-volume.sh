#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
if [[ "${SIMVA_KAFKA_VERSION%%.*}" -ge 7 ]]; then
    declare -A folders_volumes=(
        ["${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/kafka/data/kafka1/data"]="kafka_data"
    )
else
    declare -A folders_volumes=(
        ["${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/kafka/data/kafka1/data"]="kafka_data",
        ["${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/kafka/data/zoo1/data"]="zoo_data",
        ["${SIMVA_DATA_HOME:-/home/vagrant/docker-stacks/data}/kafka/data/zoo1/datalog"]="zoo_datalog"
    )
fi

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_HOME}/bin/volumectl.sh" migrate "$folder" "$volume"
done