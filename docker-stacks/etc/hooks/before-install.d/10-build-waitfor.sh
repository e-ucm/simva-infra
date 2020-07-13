#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_CONTAINER_TOOLS_HOME}/wait-for" ]]; then
    # Build golang version of wait-for for those containers that does not have bash installed.

    tmp_dir=$(mktemp -d)
    docker run --rm -it \
      -e CGO_ENABLED=0 \
      -e WAIT_FOR_REPO=https://github.com/alioygur/wait-for \
      -e WAIT_FOR_COMMIT=a2569b146c861c574e62d416699b78efe66ed883 \
      -v ${tmp_dir}:/app \
      amd64/golang:1.13 bash -c '\
    git clone ${WAIT_FOR_REPO} /go/wait-for; \
    cd /go/wait-for; \
    git checkout ${WAIT_FOR_COMMIT}; \
    go build -v -a -installsuffix cgo -o /app/wait-for; \
    '
    mv "${tmp_dir}/wait-for" "${SIMVA_CONTAINER_TOOLS_HOME}"
fi