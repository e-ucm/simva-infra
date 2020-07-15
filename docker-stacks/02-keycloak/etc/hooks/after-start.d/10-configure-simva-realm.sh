#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

exit 0

# XXX For now we are importing the realm during start
kcadm config truststore --trustpass "changeit" /home/vagrant/docker-stacks/config/tls/truststore.jks
kcadm config credentials --server https://sso.external.test/auth --realm master --user admin --password password
simva_realm_exists=$(kcadm get realms --fields realm,enabled | jq 'map(select(.realm=="simva")) | length')

if [[ "${simva_realm_exists}" != "1"  ]]; then

fi