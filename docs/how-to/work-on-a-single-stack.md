# Operate on a single stack

Every `./simva` command takes an optional stack argument. Without one it operates on the
whole `SIMVA_STACKS` set, in dependency order; with one it operates only on that stack's
compose project, its hooks and its markers.

```bash
./simva start   02-keycloak/     # only Keycloak, waiting for its dependencies
./simva stop    07-simva/
./simva log     05-kafka/        # docker compose logs -f --tail 100
./simva build   08-tmon/
./simva backup  03-limesurvey/
./simva restore 02-keycloak/
./simva purge   09-logs/
```

## When operating on one stack is enough

- **A service that won't come up.** Start only it and watch its log; the hooks for the other
  stacks do not run, which makes the noise much smaller.
- **A component upgrade.** See [upgrade-a-stack.md](./upgrade-a-stack.md) — you can hand the
  stack to `start` directly; version detection is per stack.
- **A destructive experiment.** `purge` and `uninstall` reverse the stack order for
  teardown (`docker compose down -v`), and per-stack means you keep everything else.

## Dependency discipline

Stacks wait for the stacks *before* them (`SIMVA_STACKS` order in
`etc/simva.install.d/simva-env.sh`): network, traefik, logs, keycloak, limesurvey, minio,
kafka, shlink, lrs, simva, tmon, pumva. `./simva start 07-simva/` assumes its dependencies
are up; if they are not, its `after-start` wait hooks will time out (`SIMVA_MAX_RETRIES`)
with messages naming exactly which host wasn't reachable.

## The stack alias

`STACK_NAME` —  the part after the dash (`keycloak`, `minio`, ...) — is exported while a
stack's hooks and compose are processed. It is what `volumectl`, `backup` and the hooks use
to address `config/<stack>`, `data/<stack>`, `backup/<stack>` and the named volumes
(`simva_<stack>_data`, `<stack>_<token>` per compose).

## The flips that live in a stack

Some choices are per-stack variables in `etc/simva.d/simva-env.sh`, for example:

- `04-minio`: `SIMVA_RUSTFS_ENABLE="true"` switches the object store from MinIO to RustFS
  (see [ADR-0012](../explanation/decisions/0012-object-storage-moved-from-minio-to-rustfs.md));
  otherwise the MinIO version decides between the pre-2022 FS layout, the 2022+ XL layout,
  and the `minio-migration-fs-to-xl.yml` migration fleet.
- `05-kafka`: `SIMVA_KAFKA_VERSION="7"` vs `"5"` selects the `-version-7.yml` vs
  `-version-5.yml` compose family; 7 runs on KRaft, 5 on ZooKeeper.
- `07-simva`: the database marker logic described in
  [migrate-the-simva-database.md](./migrate-the-simva-database.md).
- `09-logs`: `COMPOSE_FILE` merges Dozzle and, only in development, Portainer.

After changing a stack-level env file, `./simva start <stack>/` re-reads it (the script
sources each stack's `etc/simva.d/simva-env.sh` before composing).