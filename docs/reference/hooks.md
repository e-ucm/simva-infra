# Hooks

Hooks are the *only* place SIMVA runs arbitrary host code around Docker. Compose manages
containers; hooks manage everything that Containers are not: realm exports, SAML keys,
certificates, buckets, markers, waits.

## Where a hook lives

```text
<stack>/etc/hooks/<phase>.d/<NN>-<name>.sh       # run for one stack
etc/hooks/<phase>.d/<NN>-<name>.sh               # global: run once for the whole operation
<stack>/etc/hooks/helpers.d/<NN>-<name>.sh      # never run directly; sourced by hooks
```

Scripts run in **lexical order** (`00-`, `10-`, `20-`…), which is the numbering contract:
lower numbers go first, dependencies go earlier. For every stack invocation the script
exports a stable environment before the hooks run:

```bash
CURRENT_STACK       # e.g. "02-keycloak"
STACK_NAME          # e.g. "keycloak"     (CURRENT_STACK minus the number-dash prefix)
STACK_HOME          # <project>/docker-stacks/02-keycloak
STACK_CONF          # <project>/docker-stacks/config/keycloak
HELPERS_STACK_HOME  # …/02-keycloak/etc/hooks/helpers.d
PATH                # …/02-keycloak/bin prepended
COMPOSE_FILE        # sourced from <stack>/etc/simva.d/simva-env.sh (+ config/<stack>/simva-env.sh overrides)
```

and *unsets* `COMPOSE_FILE`/`COMPOSE_PATH_SEPARATOR` afterwards so one stack's selection
never leaks into the next.

## Lifecycle phases and their folders

The same phase name selects its **`before-<phase>.d`** folder (run first, for the whole set,
then per stack) and its **`<after: after-<phase>.d | purge: purge.d | restore: restore.d |
backup: backup.d>`** folder (run per stack, then for the whole set). The exception is
purge's global pass, which runs `etc/hooks/purge.d` only if *no* stack remains initialized.

| Phase | Before-folder (`etc/hooks/before-<phase>.d`) | After-folder | Runs from command |
| --- | --- | --- | --- |
| `install` | `before-install.d` | `after-install.d` | `./simva install` |
| `start` | `before-start.d` | `after-start.d` | `./simva start/restart`, also inside `migrate_db` and `changeConfig` |
| `stop` | `before-stop.d` | `after-stop.d` | `./simva stop/restart`, also `purge` teardown of stacks in newer flows |
| `backup` | `before-backup.d` | `backup.d` | `./simva backup` |
| `restore` | `before-restore.d` | `restore.d` | `./simva restore` |
| `uninstall` | `before-uninstall.d` | `after-uninstall.d` | `./simva uninstall` |
| `purge` | `before-purge.d` | `purge.d` (per stack; global only when nothing remains initialized) | `./simva purge` |
| `upgrade` | `before-upgrade.d` | `after-upgrade.d` | internal, from `start` when versions differ |
| `migrate` | `before-migrate.d` | `after-migrate.d` | internal, per upgrade version step |
| `migrateDomain` | `before-migrateDomain.d` | `after-migrateDomain.d` | internal, from `start` when the domain differs |
| `migrate_db` | `before-migrate-db.d` | `after-migrate-db.d` | `./simva migrate_db` |
| `changeConfig` | `before-changeConfig.d` | `after-changeConfig.d` | internal (config regeneration) |

## What an operator actually sees happening

**install** — before: checkout/download helper binaries (Keycloak CLI, extension jars),
create the wildcard certificate + truststore (`01-traefik`), prepare SAML and realms. After:
wait until the stack's endpoint answers (`wait-available.sh`), doubling the budget on a
first install.

**start** — before: marker checks (`00-migrate-to-volume.sh`), profiling, code checkout for
the dev clones. After: wait for the API and front to be available, install the real
certificate once Mongo/SQLite migrations finish, wait for the migration fleet.

**backup / restore** — `backup.d`: export the realm, dump the databases, archive the buckets,
copy `config/tls`. `restore.d`: recreate volumes and permissions, unpack the archives.

**purge** — `00-remove-data-and-config.sh` style scripts delete `config/<stack>/` and
`data/<stack>/`.

## Marker files (the state hooks read and write)

The upgrade/domain machinery persists decided state as dot-files under `data/<stack>/`:

| Marker | Written by | Meaning |
| --- | --- | --- |
| `.initialized` | `start` after first successful bring-up | a `stop`/`restart` is now a session, not a first launch |
| `.version` | version bump machinery (also `00-migrate-to-volume.sh` in some stacks) | the installed `SIMVA_<STACK>_VERSION` that gates upgrades |
| `.externaldomain` | domain machinery on first `start` and on migration | the domain whose `.pem`/certs are in `config/tls/` |
| `sqlite_init` / `migration_sqlite_in_progress` | scripted SQLite migration hooks | which compose set `07-simva` selects |

Hooks read these to decide what to do; anything else that needs state should store it under
`data/<stack>/` too, because that is the folder that backup, restore and purge all know
about.

## Helper libraries in `bin/` and `helpers.d`

- `bin/wait-available.sh`, `wait-available-with-connection.sh` — polling waits used by
  `after-start.d`; honour `SIMVA_MAX_RETRIES`.
- `bin/backup-restore.sh` — the tar/copy primitives behind backup and restore.
- `bin/volumectl.sh` — named-volume helper (init, backup, restore volume contents).
- `bin/get-or-generate.sh`, `bin/check-checksum.sh`, `bin/check-certificate-valid.sh` —
  idempotency and integrity checks.
- `bin/gomplate` — the vendored template renderer used to generate config files inside hooks.
- `01-traefik/etc/hooks/helpers.d/0*.sh` — the certificate/truststore installers shared
  across Traefik-related stacks.

## See also

- [cli.md](./cli.md) — which command triggers which phase
- [configuration-and-state](../explanation/configuration-and-state.md) — why hooks exist at all