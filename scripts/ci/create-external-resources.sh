#!/usr/bin/env bash
set -euo pipefail

for vol in \
    kc_maria_db_data \
    kc_maria_db_backup_data \
    ls_upload \
    ls_tmp \
    ls_etc \
    ls_maria_db_data \
    ls_maria_db_backup_data \
    minio_data \
    kafka_data \
    shlink_db \
    shlink_config \
    simva_sqlite_data \
    simva_mongodb_data \
    simva_mysql_data \
    simva_trace_allocator_data \
    simva_trace_allocator_logs \
    simva_storage_data \
    simva_api_logs \
    simva_front_logs \
    simva_bloom_filter_data \
    dockhand_data; do
    docker volume inspect "$vol" >/dev/null 2>&1 || docker volume create "$vol" >/dev/null
done

docker network inspect traefik_services traefik_admin --format 'network {{.Name}} ({{.Driver}})'
docker volume ls --format '{{.Name}}' \
    | grep -E '^(kc_maria|ls_|minio|kafka|shlink|simva|dockhand)' \
    | sort \
    | sed 's/^/volume /'
