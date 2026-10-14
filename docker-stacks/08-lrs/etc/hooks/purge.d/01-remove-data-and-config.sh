#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${SIMVA_BIN_HOME}/purge-file-if-exist.sh" \
    "${SIMVA_DATA_HOME}/lrs/.initialized" \
    "${SIMVA_DATA_HOME}/lrs/.externaldomain" \
    "${SIMVA_DATA_HOME}/lrs/.version"

# Volumes created by docker compose before the postgres data moved to an external volume.
# Compose names them after the stack folder (e.g. 08-lrs_pgdata, 11-lrs_pgdata), so they change
# every time a stack is renumbered. They are removed too, otherwise a purge followed by a fresh
# install would restore the purged data through the migration.
for volume in $(docker volume ls -q --filter "name=lrs_pgdata" || true); do
    "${SIMVA_BIN_HOME}/volumectl.sh" delete "$volume"
done