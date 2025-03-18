#!/usr/bin/env bash
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -e ${SIMVA_CA_FILE} ]]; then
  echo 1>&2 "Check if ${SIMVA_CA_FILE} is already imported into ${JDK_TRUSTORE}";
  keytool -list -keystore ${JDK_TRUSTORE} -storepass "${JDK_TRUSTORE_PASSWORD}" -alias "${SIMVA_CA_ALIAS}" >/dev/null 2>&1;
  ca_already_imported=$?;
  if [[ ${ca_already_imported} -ne 0 ]]; then
    echo 1>&2 "Not imported, importing ...";
    launch_bash_options=$-
    set +e
    keytool -importcert -trustcacerts -noprompt -cacerts -storepass "${JDK_TRUSTORE_PASSWORD}" -file "${SIMVA_CA_FILE}" -alias "${SIMVA_CA_ALIAS}";
    if [[ $launch_bash_options =~ e ]]; then
      set -e
    fi
    echo 1>&2 "${SIMVA_CA_FILE} imported";
  else
    echo 1>&2 "${SIMVA_CA_FILE} already imported";
  fi
fi