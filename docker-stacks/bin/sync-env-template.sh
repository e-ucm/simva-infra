#!/usr/bin/env bash
# Keeps the untracked etc/simva.d/simva-env[.dev].sh in sync with the tracked *.example.sh templates.
#   sync-env-template.sh sync <example> <local>   create local from template / append missing exports
#   sync-env-template.sh check <local>...          fail if a default placeholder is still present
set -euo pipefail

PLACEHOLDER="CHANGEME1234"

sync_file() {
    local example="$1" local_file="$2"
    [[ -f "$example" ]] || { echo >&2 "Template not found: $example"; return 1; }
    if [[ ! -f "$local_file" ]]; then
        cp "$example" "$local_file"
        echo "Created ${local_file} from $(basename "$example")"
        return 0
    fi
    local added=() line var backup=""
    while IFS= read -r line; do
        var="${line#export }"; var="${var%%=*}"
        if ! grep -qE "^[[:space:]]*(export[[:space:]]+)?${var}=" "$local_file"; then
            if [[ -z "$backup" ]]; then
                mkdir -p "$(dirname "$local_file")/backup"
                backup="$(dirname "$local_file")/backup/$(basename "$local_file" .sh)-pre-sync-$(date +%Y%m%d-%H%M%S).sh"
                cp "$local_file" "$backup"
                [[ -n "$(tail -c1 "$local_file")" ]] && echo >> "$local_file"
                printf '\n# Added from %s on %s\n' "$(basename "$example")" "$(date +%F)" >> "$local_file"
            fi
            echo "$line" >> "$local_file"
            added+=("$var")
        fi
    done < <(grep -E '^export [A-Za-z_][A-Za-z0-9_]*=' "$example")
    if ((${#added[@]})); then
        echo "New variables added to ${local_file}: ${added[*]}"
    fi
}

# Variables present in the local file but missing from the template are added to the template,
# with secret-looking values replaced by the placeholder so nothing sensitive is ever written to a tracked file.
promote_file() {
    local example="$1" local_file="$2"
    [[ -f "$example" && -f "$local_file" ]] || return 0
    local added=() line var val header=0
    while IFS= read -r line; do
        var="${line#export }"; var="${var%%=*}"
        if ! grep -qE "^[[:space:]]*(export[[:space:]]+)?${var}=" "$example"; then
            if ((!header)); then
                [[ -n "$(tail -c1 "$example")" ]] && echo >> "$example"
                printf '\n# Added from local %s on %s\n' "$(basename "$local_file")" "$(date +%F)" >> "$example"
                header=1
            fi
            if [[ "$var" =~ (PASS|SECRET|TOKEN|_KEY) ]]; then
                echo "export ${var}=\"${PLACEHOLDER}\"" >> "$example"
            else
                echo "$line" >> "$example"
            fi
            added+=("$var")
        fi
    done < <(grep -E '^export [A-Za-z_][A-Za-z0-9_]*=' "$local_file")
    if ((${#added[@]})); then
        echo "New variables added to template $(basename "$example"): ${added[*]}"
    fi
}

check_file() {
    local f="$1"
    [[ -f "$f" ]] || return 0
    grep -nE "^[[:space:]]*(export[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*=.*${PLACEHOLDER}" "$f" \
        | sed -E "s|^([0-9]+):[[:space:]]*(export[[:space:]]+)?([A-Za-z0-9_]+)=.*|  \3 (${f##*/}:\1)|"
}

case "${1:-}" in
    sync) promote_file "$2" "$3"; sync_file "$2" "$3" ;;
    check)
        shift
        out=""
        for f in "$@"; do out+="$(check_file "$f" || true)"$'\n'; done
        out="$(echo "$out" | sed '/^$/d')"
        if [[ -n "$out" ]]; then
            echo >&2 "ERROR: these secrets still have the default value '${PLACEHOLDER}' and must be changed before starting:"
            echo >&2 "$out"
            exit 1
        fi ;;
    *) echo >&2 "usage: $0 sync <example> <local> | check <local>..."; exit 2 ;;
esac
