# Migrate the SIMVA database to SQLite

The SIMVA API's own database migrated from **MongoDB** to **SQLite** (see
[ADR-0011](../explanation/decisions/0011-the-simva-database-moved-to-sqlite.md)). The
migration is driven by *two plain files* that the compose-file selectors react to:

- `data/simva/migration_sqlite_in_progress` — while present, `07-simva` launches **only** the
  MongoDB + the one-shot `mongodb_migration` container (a Python script that reads Mongo and
  writes `simva_data.db`),
- `data/simva/sqlite_init` — once present, the API runs against SQLite.

You do not touch either file by hand. `./simva migrate_db` owns them.

## Migrate from MongoDB to SQLite

```bash
cd docker-stacks && sudo su
./simva migrate_db 07-simva/
```

What you will see, in order:

1. a regular `backup` of the SIMVA stack (only if it had been initialized),
2. the start of the migration fleet — Mongo plus the builder container — because the
   `migration_sqlite_in_progress` marker made the stack select
   `docker-compose.migrate_mongo.yml`,
3. `after-start.d/00-wait-container-finished-migration.sh` watching
   `docker compose wait mongodb_migration`, then deleting the progress marker and creating
   `sqlite_init`,
4. the stack stops, and starts again in the SQLite compose set.

The API's SQLite file is `simva_data.db`, held in the named volume `simva_sqlite_data` —
the migration container writes it while Mongo is still up, then the app takes over from it.

Verify:

```bash
ls -la data/simva/            # sqlite_init is there, migration_sqlite_in_progress is gone
./simva start 07-simva/
```

## Going back to MongoDB

The reset is documented in `docker-stacks/07-simva/MIGRATION_MONGO_SQLITE.MD`:

```bash
./simva uninstall 07-simva/
rm -rf data/simva/sqlite_init
docker volume rm simva_sqlite_data
./simva start 07-simva/
```

Without `sqlite_init`, the stack's compose selector falls back to the standard MongoDB set,
and a fresh `simva_sqlite_data` volume is created empty. Note that `migrate_db` refuses to
re-run once `sqlite_init` exists (the `before-migrate-db` hook exits early), so this
"Mongo again" path is a deliberate, declared reset — back your data up first.

## MySQL? footnotes

A `docker-compose.mysql.yml` and a *mongo→mysql* migration script existed briefly
(2025-12). SQLite replaced that direction as the local/session database; if you still have
MySQL compose files around, they belong to that intermediate experiment and are not the
supported target.

## See also

- [reference/stacks.md](../reference/stacks.md) — `07-simva` compose selection
- [explanation/decisions/0011-the-simva-database-moved-to-sqlite.md](../explanation/decisions/0011-the-simva-database-moved-to-sqlite.md)