#!/bin/sh
set -eu
if [ "${DEBUG:-false}" = "true" ]; then
    set -x
fi

echo "Wait available : $@"
if [ $# -lt 1 ]; then
    echo >&2 "missing name";
    exit 1;
fi
stack_name=$1

if [ $# -lt 2 ]; then
    echo >&2 "missing host";
    exit 1;
fi
stack_host=$2

if [ $# -lt 3 ]; then
    echo >&2 "missing check redirect";
    exit 1;
fi
check_redirect=$3

if [ $# -lt 4 ]; then
    echo >&2 "missing cacert path";
    exit 1;
fi
cacert=$4
cacert_opt=""
wget_secure=""
if [ "$cacert" = "false" ] || [ -z "$cacert" ]; then
  cacert=""
else
  cacert_opt="--cacert $cacert"
  # wget cannot pin a CA (busybox wget has no such option), so the probe skips
  # verification when it has to fall back to wget against a self-signed host.
  wget_secure="--no-check-certificate"
fi

payload=${5:-}

mc_max_retries=${SIMVA_MAX_RETRIES:-${MC_MAX_RETRIES:-20}}
wait_time=${SIMVA_WAIT_TIME:-${MC_WAIT_TIME:-10}}
count=${mc_max_retries};
done="ko";
# host, host:port or scheme://host[:port][/path]: split host and port so a
# socket probe can be used when no HTTP client is installed in the image.
probe_host=""
probe_port=""
target_no_path=${stack_host#*://}
target_no_path=${target_no_path%%/*}
case "$target_no_path" in
    *:*)
        probe_host=${target_no_path%:*}
        probe_port=${target_no_path##*:}
        ;;
    *)
        probe_host=$target_no_path
        probe_port=""
        ;;
esac
case "$stack_host" in
    https://*) [ -n "$probe_port" ] || probe_port=443 ;;
    *) [ -n "$probe_port" ] || probe_port=80 ;;
esac

tcp_available() {
    if ! command -v nc >/dev/null 2>&1; then
        echo >&2 "$stack_name: neither curl, wget nor nc are available, cannot probe $stack_host";
        exit 1;
    fi
    nc -z -w 5 "$probe_host" "$probe_port" >/dev/null 2>&1
}

http_available() {
    if command -v curl >/dev/null 2>&1; then
        code="000"
        if [ "$check_redirect" = "true" ]; then
            if [ -n "$payload" ]; then
                code=$(curl -s $cacert_opt -u $payload -L --write-out "%{http_code}" "$stack_host" --output /dev/null 2>/dev/null) || code="000";
            else
                code=$(curl -s $cacert_opt -IL --write-out "%{http_code}" "$stack_host" --output /dev/null 2>/dev/null) || code="000";
            fi
        else
            if [ -n "$payload" ]; then
                code=$(curl -s $cacert_opt -u $payload --write-out "%{http_code}" "$stack_host" --output /dev/null 2>/dev/null) || code="000";
            else
                code=$(curl -s $cacert_opt --write-out "%{http_code}" "$stack_host" --output /dev/null 2>/dev/null) || code="000";
            fi
        fi
        case "$code" in
            2*) return 0 ;;
        esac
        return 1
    fi
    if command -v wget >/dev/null 2>&1; then
        # wget follows redirects itself and only exits 0 on a completed
        # transfer, which is close enough for a readiness probe. The basic
        # auth payload is curl-only; no container probe uses it.
        wget -q -T 15 -O /dev/null $wget_secure "$stack_host" >/dev/null 2>&1 && return 0
        return 1
    fi
    tcp_available
}

while [ "$count" -gt 0 ] && [ "$done" != "ok" ]; do
  echo 1>&2 "Checking $stack_name availability: $((${mc_max_retries}-$count+1)) pass";
  set +e
  case "$stack_host" in
      http://*|https://*)
          http_available
          probe_result=$?
          ;;
      *)
          tcp_available
          probe_result=$?
          ;;
  esac
  set -e
  if [ "$probe_result" -eq 0 ]; then
    done="ok";
  else
    echo 1>&2 "$stack_name not available, waiting ${wait_time}s";
    sleep ${wait_time};
  fi;
  count=$((count-1));
done;
if [ "$count" -eq 0 ] && [ "$done" != "ok" ]; then
  echo 1>&2 "$stack_name not available !";
  exit 1
fi;
if [ "$done" = "ok" ]; then
  echo 1>&2 "$stack_name available !";
fi;
