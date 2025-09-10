#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

_check_checksum() {
    folder=$1
    sha256sumfile="$2"
    sha256sumNewfile="${sha256sumfile}-new"
    # Calculate checksums of package.json and package-lock.json
    pushd $1 > /dev/null 2>&1
    sha256sum $3 > ${sha256sumNewfile}
    newSha=$(cat ${sha256sumNewfile})
    popd > /dev/null 2>&1
    # Verify checksums of current files
    if [ -e "${sha256sumfile}" ]; then 
        oldSha=$(cat ${sha256sumfile})
    else 
        oldSha=""
    fi
    echo $oldSha
    echo $newSha
    # If checksums do not verify -> rebuild dependencies
    if [[ ! ${newSha} == ${oldSha} ]]; then
        echo "DIFFERENTS"
        cp ${sha256sumNewfile} ${sha256sumfile}
        rm -f $sha256sumNewfile
        return 1
    else 
        echo "SAME FILE"
        rm -f $sha256sumNewfile
        return 0
    fi
}