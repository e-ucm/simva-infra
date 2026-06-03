 #!/usr/bin/env bash
 set -euo pipefail
 [[ "${DEBUG:-false}" == "true" ]] && set -x

copy_if_missing_in_ls_etc() {
  local src_dir="$1"
  local file_name="$2"

  if [[ ! -f "${src_dir}/${file_name}" ]]; then
    return 0
  fi

  if "${SIMVA_BIN_HOME}/volumectl.sh" execcheck "ls_etc" "/ls_etc" "[ -f /ls_etc/${file_name} ]" >/dev/null 2>&1; then
    echo "${file_name} already exists in ls_etc volume, skipping copy"
    return 0
  fi

  "${SIMVA_BIN_HOME}/volumectl.sh" copylv "${src_dir}" "ls_etc" "${file_name}" "${file_name}" false
}

if [[ -d "${SIMVA_CONFIG_HOME}/limesurvey/etc" ]]; then
    if [[ -f "${SIMVA_CONFIG_HOME}/limesurvey/etc/config.php" ]]; then
        "${SIMVA_BIN_HOME}/volumectl.sh" copylv "${SIMVA_CONFIG_HOME}/limesurvey/etc" "ls_etc" "config.php" "config.php" false
    fi
    copy_if_missing_in_ls_etc "${SIMVA_CONFIG_HOME}/limesurvey/etc" "security.php"
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