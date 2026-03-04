#!/usr/bin/env bash
set -euo pipefail

# Usage: check-certificate-valid.sh <certificate.pem>
# Returns 0 if valid, 1 if expired

cert_file="$1"
if [[ ! -f "$cert_file" ]]; then
    echo "File not found: $cert_file"
    exit 2
fi
enddate=$(openssl x509 -noout -enddate -in "$cert_file" | cut -d= -f2)
enddate_epoch=$(date -d "$enddate" +%s)
now_epoch=$(date +%s)
if [ "$enddate_epoch" -le "$now_epoch" ]; then
    echo "Expired: $cert_file (NotAfter: $enddate)"
    exit 1
else
    echo "Valid: $cert_file (NotAfter: $enddate)"
    exit 0
fi
