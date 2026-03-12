#!/usr/bin/env bash
docker builder prune -f --filter "until=$(( 7 * 24 ))h"
docker image prune -a -f --filter "until=$(date +'%Y-%m-%dT%H:%M:%S' --date='-15 days')"

count=0
for vol in $(docker volume ls -f dangling=true -q); do
    docker volume rm $vol
    (( count++ ))
done

echo "Volumes removed: $count"