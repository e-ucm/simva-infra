# `./simva` command reference

`docker-stacks/simva` is a single Bash script that owns the whole lifecycle. Every command:

- requires **root** (`require_root`, enforced once per run),
- runs `check_dependencies` and aborts listing the first missing binary from
  `DEPENDENCIES`,
- launches the Docker daemon itself if `docker info` fails (`check_docker_launched`),
- operates on the whole `SIMVA_STACKS` set unless you pass stack paths,
- accepts stack paths with or without the trailing slash (`07-simva/`, `07-simva`).

```text
Usage: simva [OPERATION | --help]

  install       Install SIMVA locally (download docker images, build required tools, etc.)
  updatecerts   With SIMVA_TLS_GENERATE_SELF_SIGNED=false, re-sync the root CA and its
                fullchain from <external-domain>.pem;--key.pem;--fullchain.pem
  uninstall     Stop and remove containers (docker compose down -v), keeping volumes? no:
                removes external volumes, keeps data/ and config/
  purge         Stop and remove containers, remove each stack's data and config/, and
                external volumes too
  start         Launch containers by stages, waiting for dependencies to become available
  stop          Gracefully stop all containers, so that no data is lost
  backup        Copy data and databases from external volumes into a backup folder
  restore       Restore data and databases into external volumes from a backup folder
  restart       Gracefully stop then start again
  log           Show a stack's logs
  build         Run docker compose build inside a stack
  help          Display the help text
```

## Per command, in detail

### `install [stack…]`

`simva install` with `wait_time=1` and `first=true`:

1. snapshots the env fragments into `backup/simva-env/` (only if changed; older versions go to `backup/old/<timestamp>/simva-env/`)
   (timestamped copies — a backup of the configuration itself),
2. for each stack in order: `before-install.d` hooks (Keycloak downloads its extension CLI,
   Traefik creates the wildcard certificate and truststore, Limesurvey checks out code, …),
   then `docker compose pull` — install **pulls images, it does not start them**,
3. writes the decision markers `data/<stack>/.externaldomain` (and `.version`, when a
   `SIMVA_<STACK>_VERSION` variable exists) so the next `start` knows what is installed,
4. `after-install.d` hooks: a stack-to-stack health wait (`wait-available`), which doubles
   its timeout on first install.

`start` calls this internally for any stack whose `.initialized` marker is missing — an
"install" is how an environment becomes bootable.

### `start [stack…]`

`simva start` with `wait_time=$DEFAULT_WAIT_TIME` and `answer=true` is **the** operation —
stopping it, every other command orbits around it. If `data/.simva-initialized` does not
exist it announces "this launch will take longer than normal" and raises the wait budget.
For each stack in order it:

1. **installs un-initialized stacks**: any stack without `data/<stack>/.initialized` gets a
   full `install` (pull + markers) first,
2. runs the global `before-start.d` hooks, then per stack the stack's `before-start.d` hooks
   — sourcing `<stack>/etc/simva.d/simva-env.sh` for the `COMPOSE_FILE` selection,
3. **domain check**: compares `SIMVA_EXTERNAL_DOMAIN` against `data/<stack>/.externaldomain`;
   if different, warns, asks "Are you sure you want to migrate to this external domain?
   (Y/N)", backs up, and runs `migrateDomain` for the stack (see
   [change-the-external-domain.md](../how-to/change-the-external-domain.md)). The Y/N answer
   is hoisted for the rest of the run (`MIGRATEDOMAINCONFIRMED`),
4. **version check**: compares `SIMVA_<STACK>_VERSION`/`versions.txt` against
   `data/<stack>/.version`; if the installed version is older, warns, asks "Are you sure you
   want to upgrade to this version? (Y/N)", backs up, and runs `upgrade` (see
   [upgrade-a-stack.md](../how-to/upgrade-a-stack.md)),
5. `docker compose up -d --remove-orphans`,
6. `after-start.d` hooks: wait for the stack's services to answer
   (`wait-available.sh`); for un-initialized stacks `SIMVA_MAX_RETRIES` and `SIMVA_WAIT_TIME`
   are doubled for the whole run,
7. touches `data/<stack>/.initialized`; when every stack ran, touches
   `data/.simva-initialized`.

### `stop [stack…]`

Graceful teardown. For each stack in reverse order, it temporarily **downgrades
`SIMVA_<STACK>_VERSION` to the recorded `data/<stack>/.version`** (falling back to the
backed-up env value), runs `before-stop.d` hooks, `docker compose stop`, `after-stop.d`
hooks, then restores the requested version. Reason: a stack is stopped with the compose file
set of the version that owns its data, not the version it might upgrade to next. Named
volumes and `data/`, `config/`, `backup/` are untouched; markers survive, so the next
`start` is a start, not an install.

### `restart [stack…]`

`stop` followed by `start`, honouring the same prompts the plain `start` does.

### `backup [stack…]`

For each stack, in order:

1. `before-backup.d` hooks, then `backup.d` hooks (plus the global `backup.d`) — the *only*
   place containers' named volumes are read (Keycloak realm export, LimeSurvey MySQL dump,
   MinIO/RustFS archive, Kafka topics dir, SIMVA DB dump, Postgres dump for the LRS, plus
   `config/tls` for Traefik),
2. `config/<stack>/` copied into `backup/<stack>/config` — `backup_data` rotates the
   previous copy into `old/<previous-.timestamp>/` as it goes,
3. `data/<stack>/` archived into `backup/<stack>/datafiles/*.tar.gz`,
4. `backup/<stack>/.timestamp` written with the current date-time.

Two implicits: a stack whose `data/<stack>/.externaldomain` is missing is treated as
uninstalled and receives a full `install` first (which also snapshots the env fragments into
`backup/simva-env/` — so the configuration **itself** is
backed up, not only the data).

### `restore [stack…]`

The exact inverse, same order: `restore.d` hooks (recreate volumes/permissions) first, then
`config/`, then the `datafiles` archive tree, then the marker files that compose uses. After
a restore, `start` treats the stack as initialized (`.initialized`, `.version`,
`.externaldomain` are back).

### `migrate_db [stack…]`

MongoDB→SQLite migration for `07-simva`:

1. `before-migrate-db.d` hooks (touch `data/simva/migration_sqlite_in_progress` unless
   `sqlite_init` already exists),
2. backup (if the stack was initialized),
3. `start 30 "false" <stack>` — the marker selects
   `docker-compose.migrate_mongo.yml:docker-compose.mongo.yml`,
4. `after-start.d` waits for `mongodb_migration` to finish (`docker compose wait`), then
   replaces the progress marker with `sqlite_init`,
5. `stop`, `after-migrate-db.d` hooks, and a final `start` of the touched stacks in SQLite
   mode.

See [migrate-the-simva-database.md](../how-to/migrate-the-simva-database.md).

### `uninstall [stack…]`

Reverse-ordered `docker compose down -v` for the requested stacks, with `before-uninstall.d`
and `after-uninstall.d` hooks. Deletes containers, networks and **named volumes**; leaves
`config/<stack>/` and `data/<stack>/` folders intact so a later `start` is still
"initialized".

### `purge [stack…]`

Uninstall plus the `purge.d` hooks, which remove `config/<stack>/` and `data/<stack>/`.
After a purge, the next `start` is a from-scratch install of every stack. Nothing in
`backup/` is touched by purge.

### `updatecerts`

With `SIMVA_TLS_GENERATE_SELF_SIGNED=false`, checks the root CA at
`<parent-of-repo>/<EXTERNAL_DOMAIN>.pem` for expiry and copies the `.pem`/`-privkey.pem`/
`-fullchain.pem` triple into `config/tls/` (see
[update-tls-certificates.md](../how-to/update-tls-certificates.md)). Errors — expired CA,
missing key, missing chain — abort with a message and refuse further startup.

### `log <stack> [docker compose logs args…]`

`docker compose logs -f --tail 100 <args>` for a single stack. You must name a stack.

### `build <stack> [docker compose build args…]`

`docker compose build <args>` for a single stack — used by developers iterating on the
checked-out repositories (see [development-mode](../tutorials/02-development-mode.md)).

### `help`

The usage text above.

## Wait-time constants

`etc/simva.install.d/simva-env.sh` defines `SIMVA_WAIT_TIME="15"` and
`SIMVA_MAX_RETRIES="20"`. `start`'s hooks use them via `wait-available.sh` to poll a
service until it answers or the retries run out; on un-initialized stacks `start` doubles
both for the whole run (and uses a 20-second basic wait), so fresh stacks get the budget
they need to initialize.

## The dispatch

Every command ultimately lands in one of the functions `main → { install, start, stop,
restart, backup, restore, migrate_db, upgrade, changeConfig, migrateDomain, uninstall,
purge, log, build }` (`docker-stacks/simva`), where `upgrade`, `changeConfig` and
`migrateDomain` are the internal machinery that `start` invokes when markers differ.