#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
  ["${SIMVA_DATA_HOME}/limesurvey/mariadb"]="ls_maria_db_data"
  ["${SIMVA_DATA_HOME}/limesurvey/mariadb-dump"]="ls_maria_db_backup_data"
  ["${SIMVA_DATA_HOME}/limesurvey/data/upload"]="ls_upload"
  ["${SIMVA_DATA_HOME}/limesurvey/data/tmp"]="ls_tmp"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$folder" "$volume"
done

if [[ -d "${SIMVA_DATA_HOME}/limesurvey/mariadb" ]]; then 
  "${SIMVA_BIN_HOME}/volumectl.sh" exec "ls_maria_db_data" "/volume_data" "
    # Set ownership recursively (mysql:mysql - 999:ping)
    chown -R 999:ping /volume_data;

    # Top-level volume directory (rwxr-xr-x)
    chmod 755 /volume_data;

    # MySQL data directories (mysql, performance_schema, limesurvey) -> 700 (rwx------)
    find /volume_data -type d -print0 | xargs -0 chmod 700;

    # All files -> 660  (rw-rw----)
    find /volume_data -type f -print0 | xargs -0 chmod 660;

    ls -lia /volume_data
  "
  rm -rf "${SIMVA_DATA_HOME}/limesurvey/mariadb"
fi

if [[ -d "${SIMVA_DATA_HOME}/keycloak/mariadb-dump" ]]; then 
  "${SIMVA_BIN_HOME}/volumectl.sh" exec "kc_maria_db_backup_data" "/dump" "
    # Set ownership recursively
    chown -R root:root /dump;

    # Directories -> 755 (rwxr-xr-x)
    find /dump -type d -print0 | xargs -0 chmod 755;

    # Files -> 644 (rw-r--r--)
    find /dump -type f -print0 | xargs -0 chmod 644;
  "
  rm -rf "${SIMVA_DATA_HOME}/keycloak/mariadb-dunp"
fi

if [[ -d "${SIMVA_DATA_HOME}/limesurvey/data/tmp" ]]; then 
  if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/data/tmp/runtime/" ]]; then 
      mkdir "${SIMVA_DATA_HOME}/limesurvey/data/tmp/runtime/"
  fi
  "${SIMVA_BIN_HOME}/volumectl.sh" exec "ls_tmp" "/ls_tmp" "
    # Set ownership recursively (wwww-data:wwww-data - 33:33)
    chown -R 33:33 /ls_tmp;

    # Directories -> 755 (rwxr-xr-x)
    find /ls_tmp -type d -print0 | xargs -0 chmod 755;

    # Files -> 664 (rw-rw-r--)
    find /ls_tmp -type f -print0 | xargs -0 chmod 664;
  "
  rm -rf "${SIMVA_DATA_HOME}/limesurvey/data/tmp"
fi

if [[ -d "${SIMVA_DATA_HOME}/limesurvey/data/upload" ]]; then 
  "${SIMVA_BIN_HOME}/volumectl.sh" exec "ls_upload" "/ls_upload" "
    # Set ownership recursively (wwww-data:wwww-data - 33:33)
    chown -R 33:33 /ls_upload;

    # Directories -> 755 (rwxr-xr-x)
    find /ls_upload -type d -print0 | xargs -0 chmod 755;

    # Files -> 664 (rw-rw-r--)
    find /ls_upload -type f -print0 | xargs -0 chmod 664;
  "
  rm -rf "${SIMVA_DATA_HOME}/limesurvey/data/upload"
fi

