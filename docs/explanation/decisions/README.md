# Architecture decision records

Twelve decisions that explain why SIMVA's infrastructure looks the way it does. Each one is
written from the repository's own history: the commits are real, the dates are real, and
where a decision was later partly reversed, the ADR says so and links the reversal.

## Reading them

Each record has:

- **Status** — Accepted, with a caveat, or accepted with an unresolved sharp edge.
- **Date** — when the decision was made, and where it took more than one commit to land.
- **Context** — the situation that made a decision necessary.
- **Decision** — what was chosen, and where to read it in the code today.
- **Consequences** — what it cost. Positive, negative, and carried forward.
- **Evidence** — the commits, so you can check them.

## Index

| # | Decision | Status | Date |
| --- | --- | --- | --- |
| [0001](./0001-numbered-stacks-one-script.md) | The environment is numbered stacks driven by one script | Accepted | 2020-06-11 → 2020-09-17 |
| [0002](./0002-stacks-declare-their-own-compose.md) | Each stack declares its own compose file set | Accepted | 2020-06-30 → 2020-07-16 |
| [0003](./0003-hooks-drive-the-lifecycle.md) | Docker runs containers; hooks run everything else | Accepted | 2020-07-13 |
| [0004](./0004-a-shared-external-network.md) | One shared, configurable external network for every service | Accepted | 2020-06-24 |
| [0005](./0005-traefik-fronts-everything.md) | Traefik fronts every published service over HTTPS | Accepted | 2020-10-02 → 2020-10-14 |
| [0006](./0006-instance-config-is-hosted-not-committed.md) | Instance configuration is hosted, not committed | Accepted, with a caveat | 2020-10-01 → 2025-12-02 |
| [0007](./0007-data-lives-in-named-volumes.md) | Data lives in named volumes, decided by markers | Accepted; the move is incomplete | 2025-09-11 → 2025-12-02 |
| [0008](./0008-backups-run-before-destructive-ops.md) | The script backs up before anything destructive | Accepted | 2025-11-04 → 2025-11-26 |
| [0009](./0009-upgrades-are-replayed-in-order.md) | Upgrades are replayed in order, one `versions.txt` step at a time | Accepted | 2024-05-27 → 2025-03-07 |
| [0010](./0010-extensions-are-pulled-not-built.md) | Extensions are pulled, not built from source | Accepted | 2025-03-05 → 2025-03-07 |
| [0011](./0011-the-simva-database-moved-to-sqlite.md) | The SIMVA database moved from MongoDB to SQLite | Accepted, with a sharp edge | 2025-12-15 → 2026-01-12 |
| [0012](./0012-object-storage-moved-from-minio-to-rustfs.md) | Object storage became pluggable, then moved to RustFS | Accepted, with a caveat | 2026-09-28 → 2026-10-07 |

## The ones that were reversed or attempted

Visible in the history because they were adopted and then taken back, or tried and left
behind:

| Attempt | Commits | What happened |
| --- | --- | --- |
| MySQL as the SIMVA database | `5d3f13f` → `1c9c2e0` | A mongo→mysql migration script arrived (2025-12-15), then SQLite won directly three days later. See [ADR-0011](./0011-the-simva-database-moved-to-sqlite.md). |
| Relocating `etc/simva.d/simva-env.dev.sh` | `bdc7fc2` → `2c8d1e2` | The dev env was first added, then moved/fixed within `simva.install.d` (2025-12-02). See [ADR-0006](./0006-instance-config-is-hosted-not-committed.md). |
| `docker-compose` vs `docker compose` | `4e0af5f` (2024-01-17) | The script moved from the dashed plugin to the subcommand form when compose v2 made the plugin the standard. |

## Known open items

Things the project has not settled, collected so they are not mistaken for decided:

1. **The named-volume migration is not complete.** Markers `.initialized`/`.version` were
   moved out so `purge` and `uninstall` could stop touching them, but some stacks still keep
   per-stack folders under `data/` and the migration scripts (`00-migrate-to-volume.sh`)
   still coexist with bind-mount-era hooks — see
   [ADR-0007](./0007-data-lives-in-named-volumes.md).
2. **Backup provenance.** `backup/<stack>/.timestamp` records *when*, not *what version*;
   restoring an OLD backup over a NEWER installed version is not guarded (the markers travel
   with the backup by design — see
   [ADR-0008](./0008-backups-run-before-destructive-ops.md)).
3. **MySQL compose files remain.** `07-simva/docker-compose.mysql.yml` and the mongo→mysql
   script are still in the tree even though SQLite is the supported target — see
   [ADR-0011](./0011-the-simva-database-moved-to-sqlite.md).
4. **RustFS flags are env-only.** There is no marker-based `Compose_FILE` switch for the
   RustFS/MinIO choice the way `07-simva` has for its database, so an operator who renames
   env flags mid-flight is responsible for the result — see
   [ADR-0012](./0012-object-storage-moved-from-minio-to-rustfs.md).

## Status vocabulary

| Status | Meaning |
| --- | --- |
| Accepted | In force, no known intent to change |
| Accepted, with a caveat | In force, with a documented sharp edge |
| Accepted; X unresolved | In force, with a named question left open inside the record |