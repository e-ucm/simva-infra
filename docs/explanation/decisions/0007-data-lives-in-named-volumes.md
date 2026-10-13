# ADR-0007 — Data lives in named volumes, decided by markers

- **Status:** Accepted; the move is incomplete
- **Date:** 2025-09-11 → 2025-12-02

## Context

For most of the project's life, container state sat in **bind mounts** pointing at
`data/<stack>/` folders on the host. That had two running wounds. First, `data/` mixes
*both* kinds of runtime data: bytes (databases, checkouts) and **decisions** (the
`.initialized`, `.version`, `.externaldomain` markers the script reads to choose between
install/upgrade/migrate). Second, a `docker compose down -v` deletes bind-mounted directories
it was given too, wiping either kind by accident.

2025-09-11 introduced a fleet of `00-migrate-to-volume.sh` hooks (`before-start.d`) that
copy each container's data folder into a Docker **named volume**; 2025-09-23 added the
`chmod` fix for the freshly-migrated volumes; 2025-12-02 fixed the scripts and the env
loading that had broken the vaults.

## Decision

Container byte-state lives in **named volumes** declared per compose project —
`minio_data`, `simva_sqlite_data`, `kc_maria_db_data`, `ls_maria_db_data`, `pgdata`,
`kafka_data`, `shlink_db/config` — while the **markers** that drive orchestration decisions
remain plain files under `data/<stack>/`. The migration hooks run once per stack (guarded by
markers so re-runs are no-ops) and take care of copying and permissions before the
containers start. Backup and restore follow the split: named volumes are captured **inside
container-side dump hooks** (`backup.d`), while `data/<stack>/` is tarred straight by
`backup-restore.sh`.

## Consequences

**Positive**

- `docker compose down -v` now deletes what the operator asked it to delete (the named
  volumes), and the decision markers survive `uninstall`, which is the point of `uninstall`
  versus `purge`.
- Volume lifecycle — init, backup, restore — is reusable via `bin/volumectl.sh` instead of
  being reassembled per stack.

**Negative**

- **The split is incomplete.** The migration scripts share a helper (`helpers.d/
  migrate-to-volume.sh`) still named after the era it replaces, and per-stack `data/`
  folders linger in several stacks' storage for things the volumes do not cover.
- **`stop`/`uninstall`/`purge` now have different data semantics** (`stop` keeps volumes,
  `uninstall` deletes them, `purge` deletes them *and* `config/`+`data/`), so operators must
  know which memory survives which command — the docs table is now load-bearing.

## Evidence

- `8ff9ccc` (2025-09-11) — "fix script migrate to volume for all containers"
- `4a194f2` (2025-09-23) — chmod when migrating
- `17e4b6b` (2025-09-25) — volume problems in keycloak and simva
- `39bf516` (2025-12-02) — migrate-to-volume scripts + simva env scripts

## Related

- [Configuration and state](../configuration-and-state.md)
- [How-to: purge or reset](../../how-to/purge-or-reset.md)
- [Reference: environment variables](../../reference/environment-variables.md) — the
  `SIMVA_*_HOME` split