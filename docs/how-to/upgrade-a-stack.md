# Upgrade a stack

Stack versions are **declared, not applied**. You edit a `SIMVA_<STACK>_VERSION` variable in
`etc/simva.d/simva-env.sh`; on the next `./simva start` the script notices the running
version (from `data/<stack>/.version`), differs from the requested one, warns, backs up, and
replays the upgrade — stack migration script by stack migration script.

## How a version is declared

Each stack group picks the image version from environment variables such as:

```bash
export SIMVA_KEYCLOAK_VERSION="26.1.3"
export SIMVA_MINIO_VERSION="RELEASE.2024-06-04T19-20-08Z"
export SIMVA_KAFKA_VERSION="7.8.0"
export SIMVA_LIMESURVEY_VERSION="6.16.16-apache"
```

and `data/<stack>/.version` records the version that was actually installed. More than one
value per stack is possible: variable names are `|`-separated in the first line of
`<stack>/etc/upgrade/versions.txt` (for example `MINIO|MINIO_MC`).

## Steps

1. Edit the version variable in `etc/simva.d/simva-env.sh` (or in a
   `<stack>/etc/simva.d/simva-env.sh` override).
2. Run `./simva start`.

`start` is the only entry point you need; it compares versions while the stack is about to
come up and, when they differ, runs the whole drill for that stack before launching it:

```text
A new version has been detected in simva-env.sh for stack <stack>.
A backup of your data is advised before upgrade.
A backup of your data will be done automatically before upgrade.
Are you sure you want to upgrade to this version ? (Y/N):
```

Answering `y`:

1. backs the stack up,
2. runs the `migrate` hooks (`before-migrate.d` / `after-migrate.d`) — e.g. Keycloak's
   per-version realm updates, MinIO's data-folder move, Kafka's KRaft/`connectors` changes,
3. walks `<stack>/etc/upgrade/versions.txt` from the previous version to the new one,
   installing and migrating each intermediate version,
4. installs the target version,
5. writes the new version into `data/<stack>/.version`.

## When the version file is consulted

```text
for each line in <stack>/etc/upgrade/versions.txt:
    if old_version <= this_line < new_version:
        install(version), start(version), stop(version)   # migration hooks run per version
```

Replaying every intermediate version is deliberate: a jump from 13 to 26 runs the 16, 24 and
26 migrations instead of skipping history. `stop` also uses the recorded version so that
containers are stopped with the compose file set of the version that owns the data.

## Downgrade is not a thing you do on purpose

`start` only upgrades. If you want *down*, restore the backup that the upgrade took:

```bash
./simva restore 02-keycloak/
# then put the old version variable back and:
./simva start
```

## See also

- [reference/environment-variables.md](../reference/environment-variables.md) — the `*_VERSION` variables
- [explanation/decisions/0009-upgrades-are-replayed-in-order.md](../explanation/decisions/0009-upgrades-are-replayed-in-order.md)