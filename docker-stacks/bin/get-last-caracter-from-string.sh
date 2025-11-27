#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

value=$1
StrLen=`echo $value | wc -c`
From=`expr $StrLen - 1`
result=$(echo $value | cut -c${From}-${StrLen})
echo $result