# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
__file_env() {
    local save_bash_options=$-
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    set +u
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    set -u
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"

    if [[ $save_bash_options =~ u ]]; then
        set -u
    fi
}

function get_or_generate_key() {
    local key=${1}
    local conf=${2:-""}
    local length=${3:-""}
    local var="SIMVA_${key^^}_KEY"
    
    var=$(echo $var | sed -e 's/[^0-9A-Za-z_]/_/g' )

    __file_env $var ''

    if [[ -z "${!var}" ]]; then
        key_secret=$(openssl rand -base64 $length)
        if [[ -e ${conf} ]]; then
            echo "export ${var}=\"${key_secret}\"" >> "${conf}"
        fi
    else
        key_secret=${!var}
    fi

    echo ${key_secret}
}

function get_or_generate_password() {
    local client=${1}
    local conf=${2:-""}
    local IsUser=${3:-""}
    local var=""
    if [[ ${IsUser} == "USER" ]]; then
        var="SIMVA_${client^^}_PASSWORD"
    else 
        var="SIMVA_${client^^}_CLIENT_SECRET"
    fi
    
    var=$(echo $var | sed -e 's/[^0-9A-Za-z_]/_/g' )

    __file_env $var ''

    if [[ -z "${!var}" ]]; then
        client_secret=$((cat /dev/urandom || true) | (LC_ALL=C tr -c -d '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' || true ) | dd bs=32 count=1 2>/dev/null)
        if [[ -e ${conf} ]]; then
            echo "export ${var}=\"${client_secret}\"" >> "${conf}"
        fi
    else
        client_secret=${!var}
    fi

    echo ${client_secret}
}

function get_or_generate_username() {
    local client=${1}
    local conf=${2:-""}
    local IsUser=${3:-""}
    local var=""
    if [[ ${IsUser} == "USER" ]]; then
        var="SIMVA_${client^^}_USER"
    else 
        var="SIMVA_${client^^}_CLIENT_ID"
    fi
    var=$(echo $var | sed -e 's/[^0-9A-Za-z_]/_/g' )

    __file_env $var ''

    if [[ -z "${!var}" ]]; then
        client_user=${client}
        if [[ -e ${conf} ]]; then
            echo "export ${var}=\"${client_user}\"" >> "${conf}"
        fi
    else
        client_user=${!var}
    fi

    echo ${client_user}
}