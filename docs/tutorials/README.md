# Tutorials

A tutorial is a **lesson**. It is written for somebody who does not know the infrastructure
yet, and it deliberately gets something working once before it explains anything. Read it
start to finish, top to bottom, without skipping.

If you already know what you want to do, skip these and use the
[how-to guides](../how-to/README.md). If you want to know *why* something works this way, read
the [explanation section](../explanation/README.md).

## Available tutorials

| Tutorial | You will | Time |
| --- | --- | --- |
| [1. Your first SIMVA environment](./01-first-launch.md) | Launch a complete local SIMVA from scratch, and log in | 40–90 min (first run) |
| [2. Development mode](./02-development-mode.md) | Turn on the development profile and reach the extra tool UIs | 20 min |
| [3. Backup and restore](./03-backup-and-restore.md) | Back up an environment, break it, and bring it back | 20 min |

## Before you start

All three assume:

- a machine that can run Docker with **root access** in the place where you launch `./simva`
  (the script demands root even for `help`),
- 4 GB RAM / 2 CPU free for a minimal environment (8 GB / 4 CPU recommended),
- the exact dependency list available in that machine: `find mkcert jq docker sha256sum
  curl git keytool htpasswd unzip dos2unix`. `./simva` runs `check_dependencies` on every
  invocation and aborts naming the first binary that is missing.

If you launch inside the Vagrant VM, Vagrant installs all of that for you. If you run Linux
natively, install them yourself first.

Everything is a single project directory. From here on, `${SIMVA}` means the cloned
`simva-infra` root, and `docker-stacks/` is where the life happens:

```bash
export SIMVA=/path/to/simva-infra
cd "$SIMVA/docker-stacks"
```