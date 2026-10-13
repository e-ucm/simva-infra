# 3. Backup and restore

SIMVA's data lives in Docker **named volumes** (the databases, the object store contents)
and under `docker-stacks/config/` and `docker-stacks/data/` (certificates, generated
configuration, markers). `./simva backup` pulls all three kinds into
`docker-stacks/backup/<stack>/`, and `./simva restore` puts them back.

This lesson backs an environment up, deletes a stack's data, and restores it — so you can
trust that green column in the status report of a real session.

## Step 1 — Take a backup

```bash
cd docker-stacks
sudo su
./simva backup
```

The command runs per stack, in stack order. For each one it:

1. runs the stack's `before-backup` hooks (e.g. Keycloak exports its whole realm,
   LimeSurvey dumps its database),
2. copies `config/<stack>/` into `backup/<stack>/config`,
3. archives `data/<stack>/` into `backup/<stack>/datafiles` (tar.gz),
4. records a timestamp in `backup/<stack>/.timestamp`.

Look at what it produced:

```bash
find backup -maxdepth 2 | sort | head -30
cat backup/02-keycloak/.timestamp
```

A second backup in the same session does not overwrite: the previous backup of a stack is
moved to `backup/<stack>/old/<timestamp>/` first (that is what `.timestamp` is for). You can
scroll versions like this forever.

## Step 2 — Break something

Delete the entire SIMVA stack data and configuration — the equivalent of a destroyed
machine:

```bash
./simva uninstall 07-simva/    # containers down -v
ls data/simva                  # now reference template and markers
```

Wait: with `-v` the named files/DB volumes are removed too. `config/simva/` and
`data/simva/` are never touched by compose, they are per-stack folders that the hooks wrote
to (the SIMVA API generated its config there). Remove them by hand to truly reset:

```bash
rm -rf data/simva config/simva
```

The front page knows something is wrong:

```bash
curl -k https://external.test/    # nothing answers, or a broken page
```

## Step 3 — Restore

```bash
./simva restore 07-simva/
./simva start 07-simva/
```

`restore` runs every stack's `restore.d` hooks (which recreate volumes and permissions),
then unpacks the saved `config` and `datafiles` folders into place. When `start` finishes,
markers such as `data/simva/.initialized` are back, so SIMVA treats this as a normal
restart rather than a fresh install.

Confirm the data came back:

```bash
curl -k https://external.test/                 # front end answers again
./simva log 07-simva
```

## Step 4 — Back everyone up like a session runner

The operations that SIMVA considers destructive are *already* guarded: `start` automatically
backs up a stack before an upgrade or a domain migration (`docker-stacks/simva` explains
itself out loud before doing so). What `start` never does is a routine backup — a nightly
cron doing `./simva backup` is left up to you, because sessions end, disks fail and named
volumes are not on the filesystem you back up by hand.

## What you now know

- Backups live on the host under `backup/<stack>/`, never inside containers.
- Backup and restore are **stack-scoped**: you can hand `02-keycloak/` or `07-simva/` to any
  of them.
- The state that compose knows about is captured by markers — `.initialized`, `.version`,
  `.externaldomain` — and the backup hooks know to include them.
- Restoring is exactly the inverse of backing up, in the same order:
  `restore.d` hooks first, then `config`, then `datafiles`.

The [how-to guides](../how-to/README.md) turn each of these knobs into a recipe, including
how to move the whole environment to a new machine.