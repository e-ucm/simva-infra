# Back up and restore

`./simva backup` and `./simva restore` are the two commands to keep an environment alive
across a panic. This guide is the *targeted* version of the
[tutorial's walkthrough](../tutorials/03-backup-and-restore.md): single stacks, schedules
and move-to-another-machine.

## Files you are copying

For a stack `NN-name` the backup is `backup/NN-name/` and contains:

| Path | What makes it important |
| --- | --- |
| `<stack>/config/` | generated configuration: certificates under `config/tls`, Keycloak realm export, LimeSurvey config, MinIO policies |
| `<stack>/datafiles/` | tars of `data/<stack>/`, notably the markers `.initialized`, `.version`, `.externaldomain` that decide *upgrade vs fresh install* |
| `<stack>/.timestamp` | the time the backup ran; the previous backup is slid into `old/<timestamp>/` |

Named volumes are captured by the stack's own `backup.d` hooks: Keycloak exports its realm
DB, LimeSurvey dumps its MySQL, SIMVA dumps its Mongo/SQLite database, MinIO archives its
buckets. That is why a *raw* copy of `config/` and `data/` is never enough on its own — the
hooks are the ones that read the live containers.

## Back up everything, or one stack

```bash
./simva backup              # the full SIMVA_STACKS set, in order
./simva backup 02-keycloak/ # just Keycloak
./simva restore 07-simva/   # just the SIMVA stack
```

Stack names are the folder paths; both `02-keycloak` and `02-keycloak/` are accepted.

## On a schedule

Put this in cron (root):

```cron
30 2 * * *  cd /opt/simva/docker-stacks && ./simva backup >/var/log/simva-backup.log 2>&1
```

Tips:

- Backups are **incremental in count, not in size**: `old/<timestamp>/` keeps full copies,
  so disk grows one full-set per run. Prune `old/` on a rotation you own.
- `backup` is idempotent and safe to run while the stack is up (hooks pause the right
  containers internally).
- The env fragments you edited by hand are snapshotted too: a stack whose
  `.externaldomain` marker is missing triggers an `install` inside `backup`, and that
  install copies `etc/simva.d/simva-env*.sh` (and the install fragment) into
  `backup/simva-env/` (only when their sha256sum changed; the previous version moves to `backup/old/<timestamp>/simva-env/`).
- Restoring a backup whose `.timestamp` is missing is refused per stack (`restore` needs it
  to know the archive exists).

## Restore on a new machine

1. Clone `simva-infra`, check out the **same branch** the old machine used.
2. Put the old `etc/` env files in place (they were instance-local, not committed).
3. `./simva install` once, without starting — it creates the volumes.
4. `./simva restore` — hooks recreate volume contents from the backup.
5. `./simva start`.

Because `.version` and `.externaldomain` come back with the restore, `start` does not try to
"upgrade" a restored install to the same version, and it does not re-run a domain migration.

## See also

- [reference/hooks.md](../reference/hooks.md) — which hook folder runs for backup and restore
- [explanation/decisions/0008-backups-run-before-destructive-ops.md](../explanation/decisions/0008-backups-run-before-destructive-ops.md)