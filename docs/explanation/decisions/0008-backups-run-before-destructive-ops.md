# ADR-0008 — The script backs up before anything destructive

- **Status:** Accepted
- **Date:** 2025-11-04 → 2025-11-26

## Context

Until November 2025, upgrade and domain-change paths ran straight into `docker compose down
-v`-class operations with no snapshot taken from the operator's point of view; the markers
(`.version`, `.externaldomain`) lived inside backup-prone folders or were not captured at all,
so a restore could resurrect a stack whose markers claimed it was a fresh install. Commit
`3634172` (2025-11-04) added the **backup/restore system**; `de0842b` (2025-11-24) fixed the
automatic backup and restore to include `.version` and `.externaldomain` in the backup —
without which restoring *loses the memory of what was installed*. The same week, certificate
handling was restructured to be checksum-verified (`34317dc`) and the whole codebase
reorganized (`373fdda`).

## Decision

Three guarantees are now structural:

1. **`./simva backup`/`restore` exist as first-class, stack-scoped commands.** Per stack they
   run trigger hooks (`backup.d`: Keycloak realm export, LimeSurvey DB dump, MinIO/RustFS
   archive, SIMVA DB dump, Postgres dump; `restore.d`: recreate volumes and permissions),
   then copy `config/<stack>/`, then tar `data/<stack>/` (markers included), keeping a
   timestamped `old/` lineage.
2. **Destructive decisions require an explicit `y`.** The `start` paths that detect a version
   bump or a domain change print a warning, announce that *"a backup of your data will be
   done automatically"*, and ask. A `y` corresponds to the backed-up event.
3. **Markers travel with the data.** `.version` and `.externaldomain` ride in the backup so
   that after a restore, `start` sees "already migrated / already at this version" instead of
   re-running an install or demolition.

## Consequences

**Positive**

- The two riskiest operations in the script (upgrade, domain migration) are now undoable
  from `backup/<stack>/`.
- Backups are understandable artifacts (`backup/03-limesurvey/config/`,
  `backup/03-limesurvey/old/<timestamp>/`), not magic.

**Negative**

- **Backups are full, not incremental.** `old/` holds complete copies; disk grows one
  full-set per run and pruning is the operator's job.
- **The backup happens *during* the interaction with the operator.** The prompt gating an
  upgrade is the moment of the strongest data (the current version), but it also means an
  unattended `./simva start` after an env edit will *park* waiting for `y` — a valid price,
  but a surprising one for automation.
- **No version guard on restore.** Restoring an old backup over a newer install is not
  refused; the markers say "old version, migrate me", which can downgrade data semantics.
  Recorded as an open item.

## Evidence

- `3634172` (2025-11-04) — adding the backup/restore system
- `de0842b` (2025-11-24) — automatic backup and restore now include `.version` and
  `.externaldomain`
- `34317dc` (2025-11-25) — certificate installation restructured + sha256sums checks
- `373fdda` (2025-11-26) — restructuring of the code

## Related

- [How-to: backup and restore](../../how-to/backup-and-restore.md)
- [Reference: cli](../../reference/cli.md) — `backup`, `restore`, and the prompt in `start`
- [ADR-0007](0007-data-lives-in-named-volumes.md) — what backup hooks read and write