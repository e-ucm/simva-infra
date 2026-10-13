# How-to guides

A how-to guide is a **recipe for one task**. It assumes you already know the domain — what a
stack is, what a marker is — and that you want the exact commands that accomplish something.

If you are new here, start with the [tutorials](../tutorials/README.md). If you want to know
*why* something is the way it is, read the [explanation](../explanation/README.md).

Almost every recipe runs inside `docker-stacks/` as root, because `./simva` demands it:

```bash
cd <simva>/docker-stacks
sudo su
```

## Changing the environment

| I want to… | Guide |
| --- | --- |
| Point every service at a new public domain | [change-the-external-domain.md](./change-the-external-domain.md) |
| Refresh or replace the TLS material for a domain | [update-tls-certificates.md](./update-tls-certificates.md) |

## Data safety

| I want to… | Guide |
| --- | --- |
| Back up one stack, or all of them, on a schedule | [backup-and-restore.md](./backup-and-restore.md) |
| Start over without keeping any bytes | [purge-or-reset.md](./purge-or-reset.md) |

## Versions and storage backend

| I want to… | Guide |
| --- | --- |
| Move SIMVA's own database from MongoDB to SQLite (or back) | [migrate-the-simva-database.md](./migrate-the-simva-database.md) |
| Upgrade a stack to a new image version, replaying the migration scripts | [upgrade-a-stack.md](./upgrade-a-stack.md) |
| Operate on a single stack instead of all twelve | [work-on-a-single-stack.md](./work-on-a-single-stack.md) |
| Switch the object store between MinIO and RustFS | [work-on-a-single-stack.md](./work-on-a-single-stack.md) |