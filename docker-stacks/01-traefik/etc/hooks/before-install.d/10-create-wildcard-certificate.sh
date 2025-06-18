#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${HELPERS_STACK_HOME}/01-install-rootCA.sh"
"${HELPERS_STACK_HOME}/02-install-wildcard-certificate.sh"
"${HELPERS_STACK_HOME}/03-install-fullchain.sh"
"${HELPERS_STACK_HOME}/04-install-trustore.sh"
"${HELPERS_STACK_HOME}/02bis-install-shlink-wildcard-certificate.sh"
"${HELPERS_STACK_HOME}/03bis-install-shlink-fullchain.sh"
"${HELPERS_STACK_HOME}/04bis-install-shlink-trustore.sh"
"${HELPERS_STACK_HOME}/05-install-dhparam.sh"
