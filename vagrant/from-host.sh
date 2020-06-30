#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

dirs="docker-stacks 00-network 01-traefik 02-keycloak 03-limesurvey 04-minio 05-kafka"
for d in $dirs; do
  rsync -avh --itemize-changes --delete --exclude "data" "/vagrant/$d/" "/home/vagrant/$d/"
done