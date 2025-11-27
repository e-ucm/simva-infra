#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ $# -lt 1 ]]; then
      echo >&2 "missing SIMVA_INFRA_GIT_REF branch to reference";
      exit 1;
fi

SIMVA_INFRA_GIT_REPO_URL=https://github.com/e-ucm/simva-infra.git
SIMVA_INFRA_GIT_REF=$1
SIMVA_INFRA_FOLDER=$(dirname "$0")/
###################################################################
######################### SIMVA INFRASTRUCTURE ####################
###################################################################
# Create source folder
# Checkout code in temp dir
tmp_dir=$(mktemp -d)
echo $tmp_dir
git clone --depth 1 --branch ${SIMVA_INFRA_GIT_REF} ${SIMVA_INFRA_GIT_REPO_URL} ${tmp_dir}
rsync_opts="--exclude docker-stacks/backup --exclude docker-stacks/data --exclude docker-stacks/config --exclude docker-stacks/etc/simva.d  --exclude docker-stacks/etc/simva.install.d/backup"
echo $rsync_opts
if [[ $# -gt 1 ]]; then
    chown -R $2 $tmp_dir
fi
rsync -avh --delete --itemize-changes ${rsync_opts} ${tmp_dir}/ ${SIMVA_INFRA_FOLDER}
