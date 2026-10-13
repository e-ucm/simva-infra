# Stacks

SIMVA is declaratively composed of **numbered stacks**. Dependencies follow the numbering,
because `SIMVA_STACKS` (in `etc/simva.install.d/simva-env.sh`) lists them in exact order:

```text
00-network  01-traefik  09-logs  02-keycloak  03-limesurvey  04-minio
05-kafka  06-shlink  11-lrs  07-simva  08-tmon  10-pumva
```

Each stack is a folder holding its own compose files, hooks and env selector
(`<stack>/etc/simva.d/simva-env.sh` sets `COMPOSE_FILE`). The same script's `start`
brings them up in `SIMVA_STACKS` order, and stops them in reverse.

## The twelve stacks

### `00-network` — the shared bridge

One `noop` service, no state. Creates the named network `traefik_services` on the bridge
interface `simva0` (`SIMVA_NETWORK_INTERFACE`) with subnet `172.30.0.0/24`
(`SIMVA_NETWORK_CIDR`) and a secondary `traefik_admin` bridge. Every other stack joins
`traefik_services`.

### `01-traefik` — the only public door

`tecnativa/docker-socket-proxy` + `traefik:2.11.3`. The socket proxy is the *only* container
that mounts `/var/run/docker.sock`; Traefik reads its own labels through it. Serves the
wildcard certificate (`config/tls/traefik*.pem`) and, in development, a `whoami` service, a
CSP reporter and the HTTP→HTTPS redirect decision (`SIMVA_LOAD_BALANCER`). Hostnames:
`traefik.external.test` (basic-auth dashboard), `sso.s…` on downstream routers.

### `09-logs` — Dozzle and Portainer

`docker-compose.dozzle.yml` always; `docker-compose.portainer.yml` only in development.
Dozzle at `logs.external.test`; Portainer at `portainer.external.test`.

### `02-keycloak` — the SSO

MariaDB + a `mariadb-backup` sidecar + `mail` + Keycloak. Compose merges
`docker-compose.yml` with a version family chosen from
`etc/upgrade/versions.txt` (`bef-18`, `sup-18`, `sup-26`). On first install hooks create the
`simva` realm, the roles (student, teaching-assistant, teacher, researcher, administrator)
and the template users documented in `02-keycloak/README.md`, configure the OAuth2/OIDC
clients (`simva`, `limesurvey`, `minio`, `tmon`, `pumva`, `simva_trace_allocator`,
`keycloak-client`, `lti_platform`) and export the realm to `config/keycloak/`. Host:
`sso.external.test`.

### `03-limesurvey` — the survey engine

MariaDB + `mariadb-backup` + LimeSurvey, SAML-authenticated from Keycloak through the
bundled `simplesamlphp` service provider (`config/limesurvey/simplesamlphp/`). Version family
selected from `SIMVA_LIMESURVEY_VERSION` (custom-4 vs sup-5). A webhook endpoint sends
bucket changes to SIMVA (`x-signature-sha256`). Host: `limesurvey.external.test`.

### `04-minio` — object storage (or RustFS)

Three mutually exclusive worlds, chosen by `SIMVA_RUSTFS_ENABLE` and the MinIO version:

| Marker / env | Compose set |
| --- | --- |
| `SIMVA_RUSTFS_ENABLE="true"` | `docker-compose-rust-fs.yml` (services `rustfs`, `rustfs-api`) |
| MinIO before 2022 | `docker-compose-minio-fs-before-2022.yml` |
| MinIO 2022+ | `docker-compose-minio-xl-after-2022.yml` |
| during FS→XL migration | `minio-migration-fs-to-xl.yml` |

Hooks create the `traces` and `backup` buckets (`SIMVA_TRACES_BUCKET_NAME`,
`SIMVA_BACKUP_BUCKET_NAME`), the event/notification config and the presigned-URL policy.
Hosts: `minio.external.test` / `minio-api`, or `rustfs.external.test` / `rustfs-api`.

### `05-kafka` — the trace pipeline

`kafka1` + `connect` on their own `kafka_services` network. `SIMVA_KAFKA_VERSION`
selects `docker-compose-version-7.yml` (KRaft) or `docker-compose.version-5.yml`
(ZooKeeper), with a `kafka-connect` sink that flushes trace statements to the `traces`
bucket. Dev-only UIs (Kafka UI) live in `docker-compose.dev-ui.yml`.

### `06-shlink` — the short URL

`shlink` + `shlink_db`, reachable on `shlink.external.test` — or on its own
`SIMVA_SHLINK_EXTERNAL_DOMAIN` (see
[change-the-external-domain.md](../how-to/change-the-external-domain.md)). Shlink's API key
is `SIMVA_SHLINK_API_KEY`; shortened links are what Limesurvey emits to skip long survey
URLs.

### `07-simva` — the API and the front end

The most stateful stack. Compose selection depends on two plain-file markers plus the
environment:

| Markers | Compose set | Meaning |
| --- | --- | --- |
| — | `docker-compose.mongo.yml` + `docker-compose.simva.mongo.yml` | MongoDB backend (historical default) |
| `data/simva/migration_sqlite_in_progress` | `docker-compose.migrate_mongo.yml` + `.mongo.yml` | one-shot migration fleet in flight |
| `data/simva/sqlite_init` | `docker-compose.simva.sqlite.yml` + `.mongo.yml` + `.simva.mongo.yml` | SQLite backend |

Services `simva-api` (port `SIMVA_SIMVA_API_EXTERNAL_PORT`) and `simva-front`; dev variants
add the profiling set (`docker-compose.dev.prof.yml`) and, in development, the Mongo UI.
This stack also holds the biggest marker inventory — `.initialized`, `.version`,
`.externaldomain` — that drives upgrades and domain migrations.

### `11-lrs` — the learning record store

`lrs` + `db` (PostgreSQL). Receives xAPI statements from the SIMVA API, keyed by
`SIMVA_LRS_API_KEY_DEFAULT`/`SECRET_DEFAULT`. Host: `lrs.external.test`.

### `08-tmon` — the dashboard

`tmon-app`, a Dash-based telemetry dashboard at `tmon.external.test`. Reads the LRS
(statements lag ≤ `SIMVA_TMON_LRS_LAG_SECONDS`) and shows what learners did.

### `10-pumva` — the composition engine

`pumva-front` + `pumva` + `pumva_logs` and its own SQLite volume, on `traefik_services` +
`kafka_services`. Hooks run an initialization pass (`docker-compose.init.yml`) that catalogues
available games before the app starts. Hosts: `pumva.external.test`, `pumva-api.external.test`.

## Compose selection mechanics

A stack's `etc/simva.d/simva-env.sh` is a Bash fragment that assigns `export COMPOSE_FILE`
from `docker-compose.yml` plus overrides. Rules found in the repo (do not memorise, read the
per-stack fragment):

- **environment**: `docker-compose.dev.*.yml` merges when `SIMVA_ENVIRONMENT=development`,
  `docker-compose.prod.yml` when `production`.
- **version**: `SIMVA_<STACK>_VERSION` picks e.g. the Keycloak family
  (`sup-26` ≥ 26, `sup-18`, `bef-18`), the LimeSurvey family (custom-4 vs sup-5), the Kafka
  KRaft/ZooKeeper pair.
- **markers**: `04-minio` and `07-simva` branch on the presence of files under
  `data/<stack>/` (the SQLite flags) and env flags (`SIMVA_RUSTFS_ENABLE`).
- Merge order matters: later files override earlier ones, so overrides stay thin.

## State a stack touches

| Thing | Where | Example |
| --- | --- | --- |
| generated config | `config/<stack>/` | `config/keycloak/`, `config/tls/`, `config/minio/` |
| runtime data & markers | `data/<stack>/` | `data/simva/sqlite_init`, `.initialized`, `.version` |
| named volumes | `<stack>_<name>` | `minio_data`, `simva_sqlite_data`, `kc_maria_db_data` |
| backups | `backup/<stack>/` | `backup/03-limesurvey/config/…` |

## See also

- [environment-variables.md](./environment-variables.md) — the stack-selecting variables
- [architecture](../explanation/architecture.md) — why the numbering exists