    #!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

extension="${STACK_HOME}/extensions/simva-lti"
filePath="${extension}/src/main/java/es/eucm/keycloak/lti13"
fileName="LTI13OIDCProtocolMapper.java"
    if [[ -e "${filePath}/${fileName}.template" ]]; then
        cat "${filePath}/${fileName}.template" \
                | sed  "s/<<SIMVA_SSO_HOST_SUBDOMAIN>>/${SIMVA_SSO_HOST_SUBDOMAIN}/g" \
                | sed  "s/<<SIMVA_EXTERNAL_DOMAIN>>/${SIMVA_EXTERNAL_DOMAIN}/g" \
                | sed  "s/<<SIMVA_SSO_REALM>>/${SIMVA_SSO_REALM}/g" \
            > "${filePath}/${fileName}"
    fi