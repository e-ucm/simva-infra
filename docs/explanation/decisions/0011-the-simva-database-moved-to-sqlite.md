# ADR-0011 — The SIMVA database moved from MongoDB to SQLite

- **Status:** Accepted, with a sharp edge
- **Date:** 2025-12-15 → 2026-01-12

## Context

The SIMVA API's state had long lived in MongoDB (`SIMVA_API_MONGO_DB`, `SIMVA_API_LTI_MONGO_DB`).
MongoDB is heavy for a single-node, single-tenant deployment: a server process, a replica
that the trace pipeline must consider, and an operator story (dump/restore) that did not
match the file-based habits of the rest of the infrastructure. Attempt #1 picked MySQL:
`5d3f13f` (2025-12-15) added a mongo→mysql Python migration script and a MySQL init path.
Three days later SQLite won directly.

## Decision

The API stores its data in a **SQLite file** (`simva_data.db`) in the named volume
`simva_sqlite_data`; MongoDB remains only as the *source* during migration. The switch is
driven by two plain-file markers under `data/simva/` — `migration_sqlite_in_progress` and
`sqlite_init` — that select the `07-simva` compose set:

- marker absent → MongoDB set (`docker-compose.mongo.yml` + `docker-compose.simva.mongo.yml`),
- `migration_sqlite_in_progress` → the migration fleet
  (`docker-compose.migrate_mongo.yml` + `.mongo.yml`): Mongo *and* a one-shot builder that
  reads Mongo and writes the SQLite file,
- `sqlite_init` → SQLite set (`docker-compose.simva.sqlite.yml` + `.mongo.yml` +
  `.simva.mongo.yml`).

`./simva migrate_db 07-simva/` (added with `52ece6b`) orchestrates the whole arc:
`before-migrate-db.d` writes the progress marker, backup, start (fleet runs), wait for
`mongodb_migration` via `docker compose wait`, flip markers, stop, start in SQLite mode.
Rollback is a declared reset (uninstall, remove the markers and the volume, start).

## Consequences

**Positive**

- Single-file persistence: the whole DB is a file in a named volume, so backup/restore and
  host-side inspection match everything else in the project.
- No replica/sharding orchestration for a single-node deployment.

**Negative**

- **Concurrency ceiling.** SQLite is a single-writer; workloads that push the API
  horizontally will outgrow it. Accepted for the current deployment shape.
- **The MySQL experiment is still in the tree.** `docker-compose.mysql.yml` and the mongo→
  mysql script linger next to the winning SQLite path; they are archaeology, not supported
  targets, and a reader has to know that (logged as an open item).
- **The migration fleet needs a real Mongo up to feed it**, so "migrate" is a small
  multi-container operation, not a one-file copy.

## Evidence

- `5d3f13f` (2025-12-15) — mongo→mysql script and mysql init (attempt #1)
- `1c9c2e0` (2025-12-18) — update to migrate to SQLite directly
- `36c1f3c` (2026-01-12) — mongo→sql for simva and pumva
- `52ece6b` (2026-01-12) — `migrate_db` command in `simva`
- `07-simva/MIGRATION_MONGO_SQLITE.MD` — the operator-facing reset

## Related

- [How-to: migrate the SIMVA database](../../how-to/migrate-the-simva-database.md)
- [Reference: stacks](../../reference/stacks.md) — the `07-simva` marker table
- [ADR-0007](0007-data-lives-in-named-volumes.md) — the volume that holds the file