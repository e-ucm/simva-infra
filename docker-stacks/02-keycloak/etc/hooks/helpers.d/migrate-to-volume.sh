#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
  ["${SIMVA_DATA_HOME}/keycloak/mariadb"]="kc_maria_db_data"
  ["${SIMVA_DATA_HOME}/keycloak/mariadb-dump"]="kc_maria_db_backup_data"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$folder" "$volume"
done

if [[ -d "${SIMVA_DATA_HOME}/keycloak/mariadb" ]]; then 
  rm -rf "${SIMVA_DATA_HOME}/keycloak/mariadb"
fi

"${SIMVA_BIN_HOME}/volumectl.sh" exec "kc_maria_db_data" "/volume_data" "
    # Set ownership recursively
    chown -R ${SIMVA_MARIA_DB_GUID}:${SIMVA_MARIA_DB_UUID} /volume_data;

    # Top-level volume directory
    chmod ${SIMVA_MARIA_DB_TOP_DIR_MODE} /volume_data;

    # MySQL data directories (mysql, performance_schema, keycloak)
    find /volume_data -type d -print0 | xargs -0 chmod ${SIMVA_MARIA_DB_DIR_MODE};

    # All files
    find /volume_data -type f -print0 | xargs -0 chmod ${SIMVA_MARIA_DB_FILE_MODE};

    ls -lia /volume_data
  "

if [[ -d "${SIMVA_DATA_HOME}/keycloak/mariadb-dump" ]]; then 
  rm -rf "${SIMVA_DATA_HOME}/keycloak/mariadb-dunp"
fi

"${SIMVA_BIN_HOME}/volumectl.sh" exec "kc_maria_db_backup_data" "/dump" "
    # Set ownership recursively
    chown -R ${SIMVA_MARIA_DB_BACKUP_GUID}:${SIMVA_MARIA_DB_BACKUP_UUID} /dump;

    # Top-level volume directory
    chmod ${SIMVA_MARIA_DB_BACKUP_TOP_DIR_MODE} /volume_data;

    # Directories
    find /dump -type d -print0 | xargs -0 chmod ${SIMVA_MARIA_DB_BACKUP_DIR_MODE};

    # Files
    find /dump -type f -print0 | xargs -0 chmod ${SIMVA_MARIA_DB_BACKUP_FILE_MODE};
  "