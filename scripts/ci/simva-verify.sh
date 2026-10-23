#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-development}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1 && pwd)"
STACKS="${ROOT}/docker-stacks"
export SIMVA_PROJECT_DIR="${STACKS}"

source "${STACKS}/etc/simva.d/simva-env.sh"
[[ -f "${STACKS}/etc/simva.d/simva-env.dev.sh" ]] && source "${STACKS}/etc/simva.d/simva-env.dev.sh"
source "${STACKS}/etc/simva.install.d/simva-env.sh"
[[ -f "${STACKS}/config/keycloak/simva-env.sh" ]] && source "${STACKS}/config/keycloak/simva-env.sh"

EXT=".${SIMVA_EXTERNAL_DOMAIN}"
URL_SSO="https://${SIMVA_SSO_HOST_SUBDOMAIN}${EXT}"
URL_TRAEFIK="https://${SIMVA_TRAEFIK_HOST_SUBDOMAIN}${EXT}"
URL_LIMESURVEY="https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}${EXT}"
URL_SIMVA_API="https://${SIMVA_SIMVA_API_HOST_SUBDOMAIN}${EXT}"
URL_FRONT="https://${SIMVA_EXTERNAL_DOMAIN}"
URL_SHLINK="https://${SIMVA_SHLINK_EXTERNAL_DOMAIN}"
URL_TMON="https://${SIMVA_TMON_DASHBOARD_HOST_SUBDOMAIN}${EXT}"
URL_LRS="https://${SIMVA_LRS_HOST_SUBDOMAIN}${EXT}"
URL_DOZZLE="https://${SIMVA_DOZZLE_HOST_SUBDOMAIN}${EXT}"

pass_count=0
fail_count=0
failures=()

pass() { pass_count=$((pass_count+1)); echo "PASS: $1"; }
fail() { fail_count=$((fail_count+1)); failures+=("$1"); echo "FAIL: $1"; }

curl_code() {
  local url
  url="${@: -1}"
  curl -sk --max-time 30 -o /dev/null -w '%{http_code}' "${@:1:$#-1}" "$url" || true
}

curl_body() {
  local url
  url="${@: -1}"
  curl -sk --max-time 30 "${@:1:$#-1}" "$url" || true
}

expect_code() {
  local label="$1" want="$2" url="$3"
  shift 3
  local code i
  code=""
  for i in $(seq 1 12); do
    code=$(curl_code "$@" "$url")
    if [[ "$code" == "$want"* ]]; then
      pass "$label (HTTP ${code})"
      return 0
    fi
    echo "  retry $label: got HTTP ${code}, waiting 15s"
    sleep 15
  done
  fail "$label (expected HTTP ${want}, got ${code})"
}

expect_code_cmd() {
  local label="$1" want="$2"
  shift 2
  local code i
  code=""
  for i in $(seq 1 12); do
    code=$("$@" 2>/dev/null || true)
    if [[ "$code" == "$want"* ]]; then
      pass "$label (HTTP ${code})"
      return 0
    fi
    echo "  retry $label: got HTTP ${code}, waiting 15s"
    sleep 15
  done
  fail "$label (expected HTTP ${want}, got ${code})"
}

expect_grep() {
  local label="$1" pattern="$2" url="$3"
  shift 3
  local body i
  body=""
  for i in $(seq 1 12); do
    body=$(curl_body "$@" "$url")
    if grep -qEi "$pattern" <<<"$body"; then
      pass "$label"
      return 0
    fi
    echo "  retry $label: pattern not found, waiting 15s"
    sleep 15
  done
  fail "$label (pattern '${pattern}' not found; body: $(head -c 200 <<<"$body"))"
}

echo "== SIMVA smoke verification (environment=${ENVIRONMENT}) =="

expect_code "Traefik dashboard unauthenticated" 401 "$URL_TRAEFIK/"
expect_code "Traefik dashboard authenticated" 200 "$URL_TRAEFIK/" \
  -u "${SIMVA_TRAEFIK_DASHBOARD_USER}:${SIMVA_TRAEFIK_DASHBOARD_PASSWORD}" -L

expect_grep "Keycloak realm OIDC metadata" '"issuer"' \
  "$URL_SSO/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration"

keycloak_user="${SIMVA_TEACHER_USER:-teacher}"
keycloak_pass="${SIMVA_TEACHER_PASSWORD:-teacher}"
token_json=$(curl -sk --max-time 30 -X POST \
  "$URL_SSO/realms/${SIMVA_SSO_REALM}/protocol/openid-connect/token" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "client_id=${SIMVA_SIMVA_CLIENT_ID}" \
  --data-urlencode "client_secret=${SIMVA_SIMVA_CLIENT_SECRET}" \
  --data-urlencode "username=${keycloak_user}" \
  --data-urlencode "password=${keycloak_pass}" \
  --data-urlencode "grant_type=password")
if [[ -n $(jq -r '.access_token // empty' <<<"$token_json" 2>/dev/null || true) ]]; then
  pass "Keycloak password grant for ${keycloak_user}"
else
  fail "Keycloak password grant for ${keycloak_user} (body: $(head -c 200 <<<"$token_json"))"
fi

expect_grep "LimeSurvey login page" "LimeSurvey" \
  "$URL_LIMESURVEY/admin/authentication/sa/login"

if docker ps --no-trunc --format '{{.Image}}' | grep -qi 'rustfs'; then
  rustfs_ui="https://${SIMVA_RUSTFS_HOST_SUBDOMAIN:-rustfs}${EXT}"
  rustfs_api="https://${SIMVA_RUSTFS_API_HOST_SUBDOMAIN:-rustfs-api}${EXT}"
  expect_code "RustFS UI health" 200 "$rustfs_ui/health/live"
  expect_code "RustFS S3 API health" 200 "$rustfs_api/health/live"
  rustfs_login=$(curl -sk --max-time 30 -X POST \
    "$rustfs_ui/api/v1/login" \
    -H 'Content-Type: application/json' \
    -d "{\"accessKey\":\"${SIMVA_RUSTFS_ACCESS_VALUE}\",\"secretKey\":\"${SIMVA_RUSTFS_SECRET_KEY}\"}" 2>/dev/null || true)
  if [[ -n $(jq -r '.sessionId // .token // empty' <<<"$rustfs_login" 2>/dev/null || true) ]]; then
    pass "RustFS console login with configured credentials"
  fi
else
  expect_code "MinIO health" 200 "https://${SIMVA_MINIO_HOST_SUBDOMAIN}${EXT}/minio/health/live"
  minio_login=$(curl -sk --max-time 30 -X POST \
    "https://${SIMVA_MINIO_HOST_SUBDOMAIN}${EXT}/api/v1/login" \
    -H 'Content-Type: application/json' \
    -d "{\"accessKey\":\"${SIMVA_MINIO_ACCESS_VALUE}\",\"secretKey\":\"${SIMVA_MINIO_SECRET_KEY}\"}")
  if [[ -n $(jq -r '.sessionId // .token // empty' <<<"$minio_login" 2>/dev/null || true) ]]; then
    pass "MinIO console login with configured credentials"
  else
    fail "MinIO console login (body: $(head -c 200 <<<"$minio_login"))"
  fi
fi

connect_ctr=$(docker ps --no-trunc --format '{{.Names}}\t{{.Image}}' | awk -F'\t' '/kafka-connect/{print $1}' | head -n1)
if [[ -n "${connect_ctr}" ]]; then
  connectors=$(docker exec "$connect_ctr" curl -sf --max-time 30 http://localhost:8083/connectors 2>/dev/null || true)
  if [[ -z "${connectors}" ]]; then
    fail "Kafka Connect REST /connectors returned nothing"
  else
    for connector in $(jq -r '.[]' <<<"${connectors}" 2>/dev/null); do
      status_json=$(docker exec "$connect_ctr" curl -sf --max-time 30 \
        "http://localhost:8083/connectors/${connector}/status" 2>/dev/null || true)
      if [[ -z "${status_json}" ]]; then
        fail "Kafka Connect connector '${connector}' status unavailable"
      elif jq -e '.connector.state == "RUNNING" and ((.tasks | length) == 0 or ([.tasks[].state == "RUNNING"] | all))' >/dev/null <<<"${status_json}"; then
        pass "Kafka Connect connector '${connector}' RUNNING"
      else
        fail "Kafka Connect connector '${connector}' not RUNNING (${status_json})"
      fi
    done
  fi
else
  fail "kafka-connect container not found"
fi

expect_grep "Shlink health" '"pass"' "$URL_SHLINK/rest/health"
expect_code "SIMVA API health" 200 "$URL_SIMVA_API/health"
trace_alloc_ctr=$(docker ps -a --no-trunc --format '{{.Names}}\t{{.Image}}' | awk -F'\t' '/simva-trace-allocator/{print $1}' | head -n1)
if [[ -z "${trace_alloc_ctr}" ]]; then
  fail "simva-trace-allocator container not found"
else
  trace_alloc_health() {
    docker exec "${trace_alloc_ctr}" node -e '
      const port = process.env.HEALTH_PORT || 3050;
      fetch("http://127.0.0.1:" + port + "/health")
        .then((r) => process.stdout.write(String(r.status)))
        .catch(() => process.stdout.write("000"))
        .finally(() => process.exit(0));
    '
  }
  expect_code_cmd "SIMVA Trace Allocator health" 200 trace_alloc_health
fi
expect_grep "SIMVA front login page" 'simva' "$URL_FRONT/users/login"
expect_code "TMon dashboard" 200 "$URL_TMON/" -L
expect_code "LRS admin UI" 200 "$URL_LRS/admin/ui" -L
expect_code "Dozzle" 200 "$URL_DOZZLE/" \
  -u "${SIMVA_TRAEFIK_DASHBOARD_USER}:${SIMVA_TRAEFIK_DASHBOARD_PASSWORD}" -L

if [[ "${ENVIRONMENT}" == "development" ]]; then
  expect_code "Kafka UI" 200 "https://${SIMVA_KAFKA_UI_HOST_SUBDOMAIN:-kafka-ui}${EXT}/" \
    -u "${SIMVA_TRAEFIK_DASHBOARD_USER}:${SIMVA_TRAEFIK_DASHBOARD_PASSWORD}" -L
  expect_code "Dockhand" 200 "https://${SIMVA_DOCKHAND_HOST_SUBDOMAIN:-dockhand}${EXT}" \
    -u "${SIMVA_TRAEFIK_DASHBOARD_USER}:${SIMVA_TRAEFIK_DASHBOARD_PASSWORD}" -L
  #expect_code "PUMVA front" 200 "https://${SIMVA_PUMVA_HOST_SUBDOMAIN:-pumva}${EXT}" -L
  #expect_code "PUMVA API" 200 "https://${SIMVA_PUMVA_API_HOST_SUBDOMAIN:-pumva-api}${EXT}" -L
  expect_code "Whoami" 200 "https://${SIMVA_WHOAMI_HOST_SUBDOMAIN:-whoami}${EXT}/" -L
fi

restarting=$(docker ps --filter status=restarting --format '{{.Names}}')
if [[ -z "${restarting}" ]]; then
  pass "No docker containers in restarting state"
else
  fail "Docker containers restarting: ${restarting}"
fi

echo
echo "== SIMVA smoke verification summary =="
echo "  passed: ${pass_count}"
echo "  failed: ${fail_count}"
if [[ ${fail_count} -gt 0 ]]; then
  printf '  - %s\n' "${failures[@]}"
  exit 1
fi