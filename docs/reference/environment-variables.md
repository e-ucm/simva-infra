# Environment variables

SIMVA configuration **is the environment**. No per-container `.env` files are hand-edited;
the exported shell variables below are what compose, the hooks and the entrypoints all read.

## Where they live (in source order)

```text
docker-stacks/etc/simva.install.d/simva-env.sh     # SIMVA_STACKS, the SIMVA_*_HOME dirs,
                                                   # wait-time constants, DERIVED defaults
docker-stacks/etc/simva.d/simva-env.sh             # global instance config: domain,
                                                   # network, versions, credentials
docker-stacks/etc/simva.d/simva-env.dev.sh         # development-only: dev subdomains,
                                                   # SIMVA_DEVELOPMENT_LOCAL, git references
<stack>/etc/simva.d/simva-env.sh                   # per-stack COMPOSE_FILE selection
<stack>/etc/simva.d/simva-env.dev.sh               # the same, but only in development
```

The `simva` script sources the install fragment, then each stack's fragment before touching
that stack, so a variable meant for one stack can live in its own `etc/simva.d/` and never
leak.

## Instance identity

| Variable | Default | Meaning |
| --- | --- | --- |
| `SIMVA_ENVIRONMENT` | `development` | selects `dev.*` vs `prod.*` compose overrides |
| `SIMVA_EXTERNAL_DOMAIN` | `external.test` | public suffix for `https://<subdomain>.<domain>` |
| `SIMVA_INTERNAL_DOMAIN` | `internal.test` | private service DNS suffix |
| `SIMVA_EXTERNAL_PROTOCOL` | `https` | scheme emitted into generated URLs |
| `SIMVA_DEVELOPMENT_LOCAL` | `false` | mount sibling repos instead of checked-out clones |
| `SIMVA_LOAD_BALANCER` | `false` | when true, keep the HTTP→HTTPS redirect off |
| `SIMVA_TLS_GENERATE_SELF_SIGNED` | `false` | `false` = your CA (see updatecerts); `true` = mkcert CA |

## Locations (set in `etc/simva.install.d/simva-env.sh`)

| Variable | Default relative to `docker-stacks/` | Contents |
| --- | --- | --- |
| `SIMVA_HOME` | `.` | the project itself |
| `SIMVA_BIN_HOME` | `bin/` | helper scripts |
| `SIMVA_DATA_HOME` | `data/` | runtime state and markers (gitignored) |
| `SIMVA_CONFIG_HOME` | `config/` | generated configuration (gitignored) |
| `SIMVA_CONFIG_TEMPLATE_HOME` | `config-template/` | gomplate templates |
| `SIMVA_BACKUP_HOME` | `backup/` | backups (gitignored) |
| `SIMVA_ETC_HOME` | `etc/` | the tracked env fragments |
| `SIMVA_TLS_HOME` | `config/tls/` | certificates, truststore, DH params |
| `SIMVA_CONTAINER_TOOLS_HOME` | `config/container-tools/` | env files reused inside containers |

## Network

| Variable | Default | Meaning |
| --- | --- | --- |
| `SIMVA_SERVICE_NETWORK` | `traefik_services` | the shared named bridge every stack joins |
| `SIMVA_NETWORK_INTERFACE` | `simva0` | bridge device name created by `00-network` |
| `SIMVA_NETWORK_CIDR` | `172.30.0.0/24` | subnet of that bridge |
| `SIMVA_HOST_EXTERNAL_IP` | `172.30.0.1` | host's address on the bridge |
| `SIMVA_KAFKA_NETWORK` | `kafka_services` | the Kafka-only bridge |
| `SIMVA_TRAEFIK_HOST_SUBDOMAIN` | `traefik` | `traefik.external.test` |

Service subdomains are all exported in `etc/simva.d/simva-env.sh`: `sso`, `mail`, `limesurvey`,
`minio`, `minio-api`, `rustfs`, `rustfs-api`, `analytics`, `simva-mongo`, `simva-api`, `shlink`,
`tmon`, `pumva-api`, `pumva`, `logs`, `lrs`.

## Versions (image pinning)

The upgrades machinery compares these against `data/<stack>/.version` and the per-stack
`etc/upgrade/versions.txt` (see [upgrade-a-stack.md](../how-to/upgrade-a-stack.md)):

| Variable | Example | Stack |
| --- | --- | --- |
| `SIMVA_TRAEFIK_VERSION` | `2.11.58` | 01 |
| `SIMVA_SOCKET_PROXY_VERSION` | `v0.5.0` | 01 |
| `SIMVA_KEYCLOAK_VERSION` | `26.1.3` | 02 |
| `SIMVA_LIMESURVEY_VERSION` | `6.16.16-apache` | 03 |
| `SIMVA_MINIO_VERSION` | `RELEASE.2024-06-04T19-20-08Z` | 04 |
| `SIMVA_KAFKA_VERSION` | `7.8.0` | 05 |
| `SIMVA_RUSTFS_ENABLE` | `true` | 04 (RustFS vs MinIO) |
| `SIMVA_LRS_SUPPORTED_VERSIONS` | `1.0.3,2.0.0` | 11 |

## Credentials and clients

All plain-text credential variables live at the bottom of `etc/simva.d/simva-env.sh` under
the "AUTHENTIFICATION USERNAME AND PASSWORD (TO MODIFY)" heading. Notable ones:

- Traefik dashboard: `SIMVA_TRAEFIK_DASHBOARD_USER`/`PASSWORD`.
- Keycloak: `SIMVA_KEYCLOAK_ADMIN_USER`/`PASSWORD`, MySQL `SIMVA_KEYCLOAK_MYSQL_*`.
- Realm users (created by hooks, enforced by `*_ALLOWED_ROLE`): `SIMVA_STUDENT_USER`,
  `SIMVA_TEACHING_ASSISTANT_USER`, `SIMVA_TEACHER_USER`, `SIMVA_RESEARCHER_USER`,
  `SIMVA_ADMINISTRATOR_USER` (passwords auto-generated unless you uncomment them).
- OAuth2 clients: `SIMVA_SIMVA_CLIENT_ID/SECRET`, `SIMVA_LIMESURVEY_CLIENT_ID/SECRET`,
  `SIMVA_MINIO_CLIENT_ID`, `SIMVA_TMON_CLIENT_ID/SECRET`, `SIMVA_PUMVA_CLIENT_ID/SECRET`,
  `SIMVA_TRACE_ALLOCATOR_CLIENT_ID/SECRET`, `SIMVA_LTI_PLATFORM_CLIENT_ID/SECRET`,
  `SIMVA_KEYCLOAK_CLIENT_CLIENT_ID/SECRET`.
- Storage: `SIMVA_MINIO_ACCESS_KEY`/`SECRET_KEY`, `SIMVA_RUSTFS_ACCESS_KEY`/`SECRET_KEY`.
- Pipeline: `SIMVA_KAFKA_CONNECT_SINK_USER`/`SECRET`, `SIMVA_SHLINK_API_KEY`,
  `SIMVA_LRS_ADMIN_*`, `SIMVA_LRS_API_KEY_*/SECRET_*`, `SIMVA_DOZZLE_USERNAME`/`PASSWORD`.

## Development only (`etc/simva.d/simva-env.dev.sh`)

| Variable | Meaning |
| --- | --- |
| `SIMVA_DEV_LOAD_BALANCER` | like `SIMVA_LOAD_BALANCER` but development-scoped |
| `SIMVA_<STACK>_GIT_REF` | the git refs checked out into `data/<stack>/` for `simva`, `simva-front`, `tmon`, `pumva`, `limesurvey` |
| dev subdomains | `whoami`, `kafka-ui`, `zoonavigator`, `phpmyadmin`, `simva-mongo-ui`, `simva-sqlite-ui`, `shlink-admin`, `jupyter`, `logs`, `portainer`, `dockhand` |

## Values that are composite, not plain

- Passwords are occasionally generated rather than fixed: commented `SIMVA_*_PASSWORD`
  lines mean "the hook generates one on first install and stores it in
  `config/container-tools/`". Uncommenting pins it.
- `COMPOSE_FILE` is per-stack, never global: `etc/simva.d/simva-env.sh` at the root does not
  set it. The per-stack fragments do — reading one is how you answer "which compose files
  run for this stack right now?".

## Changing any of it

1. Edit the fragment (root or stack-level).
2. Run the relevant `./simva` command (`start` re-sources everything per stack).
3. Variables read by `start` for its upgrade/domain decisions are the ones to change *before*
   `./simva start`, because that command backs up first — as designed, not as an accident.