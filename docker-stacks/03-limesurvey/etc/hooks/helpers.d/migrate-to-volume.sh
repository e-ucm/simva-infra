#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
  ["${SIMVA_DATA_HOME}/limesurvey/mariadb"]="ls_maria_db_data"
  ["${SIMVA_DATA_HOME}/limesurvey/mariadb-dump"]="ls_maria_db_backup_data"
  ["${SIMVA_DATA_HOME}/limesurvey/data/upload"]="ls_upload"
  ["${SIMVA_CONFIG_HOME}/limesurvey/etc"]="ls_etc"
  ["${SIMVA_DATA_HOME}/limesurvey/data/tmp"]="ls_tmp"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$folder" "$volume"
done

if [[ -d "${SIMVA_DATA_HOME}/limesurvey/mariadb" ]]; then 
  rm -rf "${SIMVA_DATA_HOME}/limesurvey/mariadb"
fi
"${SIMVA_BIN_HOME}/volumectl.sh" exec "ls_maria_db_data" "/volume_data" "
    # Set ownership recursively
    chown -R ${SIMVA_MARIA_DB_GUID}:${SIMVA_MARIA_DB_UUID} /volume_data;

    # Top-level volume directory
    chmod ${SIMVA_MARIA_DB_TOP_DIR_MODE} /volume_data;

    # MySQL data directories (mysql, performance_schema, limesurvey)
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
    chmod ${SIMVA_MARIA_DB_BACKUP_TOP_DIR_MODE} /dump;

    # Directories
    find /dump -type d -print0 | xargs -0 chmod ${SIMVA_MARIA_DB_BACKUP_DIR_MODE};

    # Files
    find /dump -type f -print0 | xargs -0 chmod ${SIMVA_MARIA_DB_BACKUP_FILE_MODE};
    ls -lia /dump
  "

if [[ -d "${SIMVA_DATA_HOME}/limesurvey/data/tmp" ]]; then 
  if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/data/tmp/runtime/" ]]; then 
      mkdir "${SIMVA_DATA_HOME}/limesurvey/data/tmp/runtime/"
  fi
  rm -rf "${SIMVA_DATA_HOME}/limesurvey/data/tmp"
fi

"${SIMVA_BIN_HOME}/volumectl.sh" exec "ls_tmp" "/ls_tmp" "
    # Set ownership recursively
    chown -R ${SIMVA_LIMESURVEY_GUID}:${SIMVA_LIMESURVEY_UUID} /ls_tmp;

    # Top-level volume directory
    chmod ${SIMVA_LIMESURVEY_TOP_DIR_MODE} /ls_tmp;

    # Directories
    find /ls_tmp -type d -print0 | xargs -0 chmod ${SIMVA_LIMESURVEY_DIR_MODE};

    # Files
    find /ls_tmp -type f -print0 | xargs -0 chmod ${SIMVA_LIMESURVEY_FILE_MODE};
    ls -lia /ls_tmp
  "

if [[ -d "${SIMVA_DATA_HOME}/limesurvey/data/upload" ]]; then 
  rm -rf "${SIMVA_DATA_HOME}/limesurvey/data/upload"
fi

"${SIMVA_BIN_HOME}/volumectl.sh" exec "ls_upload" "/ls_upload" "
    # Set ownership recursively
    chown -R ${SIMVA_LIMESURVEY_GUID}:${SIMVA_LIMESURVEY_UUID} /ls_upload;

    # Top-level volume directory
    chmod ${SIMVA_LIMESURVEY_TOP_DIR_MODE} /ls_upload;

    # Directories
    find /ls_upload -type d -print0 | xargs -0 chmod ${SIMVA_LIMESURVEY_DIR_MODE};

    # Files
    find /ls_upload -type f -print0 | xargs -0 chmod ${SIMVA_LIMESURVEY_FILE_MODE};
    ls -lia /ls_upload
  "

if [[ -d "${SIMVA_CONFIG_HOME}/limesurvey/etc" ]]; then
  if [[ -f "${SIMVA_CONFIG_HOME}/limesurvey/etc/config.php" ]]; then
    "${SIMVA_BIN_HOME}/volumectl.sh" copylv "${SIMVA_CONFIG_HOME}/limesurvey/etc" "ls_etc" "config.php" "config.php" false
  fi
  if [[ -f "${SIMVA_CONFIG_HOME}/limesurvey/etc/security.php" ]]; then
    "${SIMVA_BIN_HOME}/volumectl.sh" copylv "${SIMVA_CONFIG_HOME}/limesurvey/etc" "ls_etc" "security.php" "security.php" false
  fi
fi

"${SIMVA_BIN_HOME}/volumectl.sh" exec "ls_etc" "/ls_etc" "
    # Set ownership recursively
    chown -R ${SIMVA_LIMESURVEY_GUID}:${SIMVA_LIMESURVEY_UUID} /ls_etc;
    
    # Top-level volume directory
    chmod ${SIMVA_LIMESURVEY_TOP_DIR_MODE} /ls_etc;

    # Directories
    find /ls_etc -type d -print0 | xargs -0 chmod ${SIMVA_LIMESURVEY_DIR_MODE};

    # Files
    find /ls_etc -type f -print0 | xargs -0 chmod ${SIMVA_LIMESURVEY_FILE_MODE};
    ls -lia /ls_etc
  "