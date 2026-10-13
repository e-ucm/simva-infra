# ADR-0012 — Object storage became pluggable, then moved to RustFS

- **Status:** Accepted, with a caveat
- **Date:** 2026-09-28 → 2026-10-07

## Context

The object store behind the trace pipeline had been MinIO-with-a-version-dependent-compose
since 2024. The 2026 deployments hit two pressure points: MinIO's OpenID/event wiring grew
heavier than the deployment wanted to carry, and the storage backend of the session
(presigned uploads, S3-style buckets) did not need a second admin UI and its policy
apparatus. The `rustfs` branch name announces the direction of travel before any decision
record existed.

## Decision

Two layers, decided one commit apart in spirit:

1. **Make the backend pluggable.** `04-minio/etc/simva.d/simva-env.sh` gains a flag,
   `SIMVA_RUSTFS_ENABLE`, that switches the whole stack's `COMPOSE_FILE` to
   `docker-compose-rust-fs.yml` (services `rustfs`, `rustfs-api`) while leaving the MinIO
   world (`minio-fs-before-2022`, `minio-xl-after-2022`, `minio-migration-fs-to-xl`)
   intact for the CLI and paths that depend on it.
2. **The deployment moves to RustFS.** The `rustfs` branch ships the RustFS compose files,
   the `SIMVA_RUSTFS_*` variables (`ACCESS_KEY`/`SECRET_KEY`, `NOTIFY_QUEUE_LIMIT`, the
   `rustfs`/`rustfs-api` subdomains), a **presigned-upload CORS** configuration for the
   future web-upload path, and event-notification wiring so the pipe from storage to Kafka
   survives the backend swap (`2956b5c`). Trace-allocator and dev-env fixes accompany the
   swap on the same branch.

## Consequences

**Positive**

- Storage backend is now a per-instance choice expressed in one env flag — the same
  "compose selection from a variable" pattern as every other stack.
- RustFS as one binary + volume removes MinIO's admin surface from the deployment's threat
  and ops footprint.
- The MinIO path is not deleted; rollback is flipping `SIMVA_RUSTFS_ENABLE=false`, not a
  re-write.

**Negative**

- **The switch is env-only, not marker-driven.** Unlike `07-simva`'s SQLite choice (markers
  on disk), there is no persisted state saying "this stack is RustFS now"; an operator who
  changes the flag mid-flight owns the resulting data-location mismatch.
- **RustFS data lands in a named volume bind whose layout is young**; backup hooks expected
  the MinIO archive shape and had to be re-checked for the new artifact set.
- **The branch is the deployment.** The RustFS work lives on the `rustfs` branch that
  deployments clone, so the decision is only fully visible there; `master`/other branches
  still carry MinIO as the default.

## Evidence

- `5702293` (2026-09-28) — "fix commands for rustfs"
- `3873c47` (2026-09-30) — secure flag in client_secrets.json
- `8e79b39` (2026-10-05) — disable local deployment flags and DB checks in dev env
- `2956b5c` (2026-10-07) — RustFS event notification configurations
- `a7236e6` (2026-10-07) — trace allocator client ID/secret in simva-env.sh
- `docker-stacks/04-minio/docker-compose-rust-fs.yml` (rustfs branch)

## Related

- [Reference: stacks](../../reference/stacks.md) — the `04-minio` marker/environment table
- [How-to: work on a single stack](../../how-to/work-on-a-single-stack.md) — the flips that
  live in a stack
- [ADR-0002](0002-stacks-declare-their-own-compose.md) — compose selection is how the switch
  is expressed