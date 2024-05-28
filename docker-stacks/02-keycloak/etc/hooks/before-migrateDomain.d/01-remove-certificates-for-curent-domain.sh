#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT:-limesurvey-fullchain.pem}" \
    "${STACK_HOME}/extensions/simva-lti/src/main/java/es/eucm/keycloak/lti13/LTI13OIDCProtocolMapper.java" \
    "${SIMVA_CONFIG_HOME}/keycloak/themes/simva/account/theme.properties"