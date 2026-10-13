# ADR-0009 — Upgrades are replayed in order, one `versions.txt` step at a time

- **Status:** Accepted
- **Date:** 2024-05-27 → 2025-03-07

## Context

For a long time the script did a crude "new version → pull and rebuild" with no notion of
*which* migration scripts an intermediate version required. Keycloak moved through multiple
schema-generations, Kafka's model changed between major versions, and a straight jump from
13 to 26 would skip the 16→24 changes that the 26 image expects on disk. `6fe5f9b`
(2024-05-27) introduced the per-stack migration menu — MinIO's compose set and a redesigned
`versions.txt` — and `c7405ca` (2025-03-07) fixed where the file lives so the machinery
could find it for every stack.

## Decision

Version handling is **declarative and sequential**:

- Each stack declares its image versions in variables (`SIMVA_KEYCLOAK_VERSION`,
  `SIMVA_MINIO_VERSION`, …) and holds a revision list in
  `<stack>/etc/upgrade/versions.txt` — e.g. Keycloak: `13.0.0 → 16.0.0 → 24.0.2 → 26.1.3`;
  a line can pair two artifacts (`MINIO|MINIO_MC`) so the MC client follows the server.
- `data/<stack>/.version` records the installed version.
- On `./simva start`, when the requested version differs, the script walks `versions.txt`
  and for every line *between* the installed and the requested version it executes the
  upgrade drill for that concrete version: backup, `migrate` hooks (which run the version's
  schema/data scripts), install that version's images, start, stop.
- The target version is then written to `data/<stack>/.version`.

So an upgrade replays **each intermediate version**, not just the delta — that is the
invariant the whole design protects.

## Consequences

**Positive**

- A 13→26 jump behaves the same as 13→16→24→26 done by hand: same scripts, same order.
- A single place (`versions.txt`) enumerates the migration steps a stack knows.
- Multi-artifact stacks (MinIO+MC) stay in lockstep through the `|`-separated lines.

**Negative**

- **There is no downgrade path.** `start` only upgrades; going back means `restore` from the
  backup the upgrade took (the backup-before-upgrade obligation from
  [ADR-0008](0008-backups-run-before-destructive-ops.md)).
- **The intermediate versions must actually boot.** Each step installs and starts the version
  to run *its* migrations — slow for a stack whose migrations are a formality.
- **A mis-ordered `versions.txt` stalls the walk** rather than failing fast; the ordering is
  trust in the file's editors.

## Evidence

- `6fe5f9b` (2024-05-27) — MinIO compose + versions.txt integrating multiple per-stack
  updates
- `c7405ca` (2025-03-07) — "fix location of upgrade versions file"
- `02-keycloak/etc/upgrade/versions.txt`, `05-kafka/etc/upgrade/versions.txt`,
  `04-minio/etc/upgrade/versions.txt` (current state)

## Related

- [How-to: upgrade a stack](../../how-to/upgrade-a-stack.md)
- [Reference: environment variables](../../reference/environment-variables.md) — the
  `SIMVA_*_VERSION` variables
- [ADR-0002](0002-stacks-declare-their-own-compose.md) — version families are chosen in the
  same fragment