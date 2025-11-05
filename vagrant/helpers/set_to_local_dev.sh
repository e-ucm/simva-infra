#!/usr/bin/env bash
set -euo pipefail

simvaenvFile="../docker-stacks/etc/simva.d/simva-env.sh"
simvadevenvFile="../docker-stacks/etc/simva.d/simva-env.dev.sh"

# Detect sed -i compatibility (macOS vs Linux)
if sed --version >/dev/null 2>&1; then
    SED_OPT=(-i)
else
    SED_OPT=(-i "")
fi

# Function to update or append export line
update_or_add_export() {
    local file="$1"
    local key="$2"
    local value="$3"

    if [[ -f "$file" ]]; then
        if grep -q "^export $key=" "$file"; then
            sed "${SED_OPT[@]}" "s|^export $key=.*|export $key=\"$value\"|" "$file"
            echo "Updated $key in $file"
        else
            echo "export $key=\"$value\"" >> "$file"
            echo "Added $key to $file"
        fi
    else
        echo "Warning: $file not found, skipping."
    fi
}

update_or_add_export "$simvaenvFile" "SIMVA_ENVIRONMENT" "development"
update_or_add_export "$simvadevenvFile" "SIMVA_DEVELOPMENT_LOCAL" "true"
