#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

VOLUME="lrs_pgdata"
LEGACY_FOLDER="${SIMVA_DATA_HOME}/lrs/data"

# Volumes created by docker compose before the postgres data moved to an external volume.
# Compose names them after the stack folder (e.g. 08-lrs_pgdata, 11-lrs_pgdata), so they change
# every time a stack is renumbered. They are never deleted here, only read from.
function list_legacy_volumes() {
    docker volume ls -q --filter "name=lrs_pgdata" | grep -v -x "${VOLUME}" || true
}

if docker volume inspect "${VOLUME}" >/dev/null 2>&1; then
    echo "📦 Volume '${VOLUME}' already exists. Skipping migration."
else
    # Most recent legacy volume first: a renumbering starts a new volume, the newest one holds the data in use
    legacy_volumes=$(list_legacy_volumes | while read -r volume; do
        echo "$(docker volume inspect "$volume" --format '{{.CreatedAt}}') ${volume}"
    done | sort -r)
    legacy_volume=$(echo "$legacy_volumes" | awk 'NF {print $2; exit}')

    if [[ -n "$legacy_volume" ]]; then
        echo "📂 Copying data from legacy volume '${legacy_volume}' into '${VOLUME}'..."
        # Stop the database first, copying a running postgres data directory is not consistent
        export RUN_IN_CONTAINER=true
        export RUN_IN_CONTAINER_NAME="db"
        source "${SIMVA_BIN_HOME}/check-docker-running.sh"
        _stop_docker_container_if_running
        "${SIMVA_BIN_HOME}/volumectl.sh" copyvv "$legacy_volume" "${VOLUME}"
        for volume in $(echo "$legacy_volumes" | awk 'NF {print $2}'); do
            if [[ "$volume" != "$legacy_volume" ]]; then
                echo "🕐 Legacy volume '${volume}' left untouched."
            fi
        done
    else
        "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$LEGACY_FOLDER" "${VOLUME}"
    fi
fi

if [[ -d "${LEGACY_FOLDER}" ]]; then
    "${SIMVA_BIN_HOME}/purge-folder-contents.sh" "${LEGACY_FOLDER}"
fi

guid="${SIMVA_LRS_PG_GUID:-999}"
uuid="${SIMVA_LRS_PG_UUID:-999}"
# Top-level volume directory
topDirectoryMod="${SIMVA_LRS_PG_TOP_DIR_MODE:-700}"
# Directories
directoryMod="${SIMVA_LRS_PG_DIR_MODE:-700}"
# Files
fileMod="${SIMVA_LRS_PG_FILE_MODE:-600}"

"${SIMVA_BIN_HOME}/volumectl.sh" exec "${VOLUME}" "/var/lib/postgresql" "
    # Set ownership recursively
    chown -R ${guid}:${uuid} /var/lib/postgresql;

    # Top-level volume directory
    chmod ${topDirectoryMod} /var/lib/postgresql;

    # Directories
    find /var/lib/postgresql -type d -print0 | xargs -0 chmod ${directoryMod};

    # Files
    find /var/lib/postgresql -type f -print0 | xargs -0 chmod ${fileMod};
    ls -lia /var/lib/postgresql;
"