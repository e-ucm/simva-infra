# SIMVA infrastructure documentation

`simva-infra` launches and manages a complete **SIMVA** environment: the **Sim**ple
**Va**lidation tool for Game Learning Analytics. It orchestrates a dozen cooperating
[Docker](https://www.docker.com/) stacks — an SSO provider (Keycloak), a survey tool
(LimeSurvey), an S3 object store (MinIO or RustFS), a trace pipeline
(Kafka + trace allocator), a short-URL service (Shlink), the SIMVA API and front end, the
TMon analysis dashboard, PUMVA, an LRS, and the log viewers — behind a single Traefik
reverse proxy.

Everything is driven by one script, `./simva`, that lives in `docker-stacks/`:

```bash
cd docker-stacks && sudo su
./simva start          # launch every stack, in dependency order
./simva backup         # back the data and config up, per stack
./simva restart        # graceful stop, then start again
```

One rule governs almost everything: **there is no impermanent state in the repository.**
Configuration comes from environment files that are loaded at runtime, generated config
lives in `config/` (untracked), and runtime data lives in named Docker volumes and under
`data/` (untracked). The clone is meant to be thrown away and re-created; your instance's
configuration is not.

## How this documentation is organised

These pages are organised with the [Diátaxis](https://diataxis.fr) method. The four
sections answer four different questions, and each one is written so it can be read on its
own:

| Section | Question it answers | Start here |
| --- | --- | --- |
| [Tutorials](./tutorials/) | *I am new here. Walk me through something that works.* | [Your first SIMVA environment](./tutorials/01-first-launch.md) |
| [How-to guides](./how-to/) | *I know the domain. Do this specific task for me.* | [Change the external domain](./how-to/change-the-external-domain.md) |
| [Reference](./reference/) | *What exactly does this command/stack accept and do?* | [The `simva` CLI](./reference/cli.md) |
| [Explanation](./explanation/) | *Why is it built this way? What were the trade-offs?* | [Decisions](./explanation/decisions/README.md) |

Do not read them in order. Pick the question you have.

## The 30 second mental model

```
your machine (Linux natively, or a Vagrant VM on Windows/Mac)
  └─ docker-stacks/            the whole project
       ├─ ./simva              one script: install | start | stop | backup | restore | ...
       ├─ NN-<name>/           twelve numbered stacks, each a docker-compose project
       │    ├─ docker-compose*.yml      the base + environment/variant overrides
       │    ├─ etc/simva.d/simva-env.sh picks the compose files and stack secrets
       │    └─ etc/hooks/<phase>.d/*.sh scripts run before/after each lifecycle phase
       ├─ etc/simva.d/simva-env.sh      the global configuration (domains, services, users)
       ├─ bin/                 shared helpers (wait-available, backup-restore, volumectl, …)
       ├─ config/              generated configuration, from config-template/ (untracked)
       ├─ data/                per-stack runtime markers and copies (untracked)
       └─ backup/              per-stack backup folders (untracked)
  └─ an external Docker network "traefik_services"
        └─ Traefik terminates TLS in front of every published service
```

Vocabulary you will meet everywhere:

- **Stack** — one numbered docker-compose project: `00-network`, `01-traefik`, `02-keycloak`,
  `03-limesurvey`, `04-minio`, `05-kafka`, `06-shlink`, `07-simva`, `08-tmon`, `09-logs`,
  `10-pumva`, `11-lrs`. The number is the launch order; `00-network` exists only to create the
  shared network.
- **Compose file set** — the `COMPOSE_FILE` variable each stack declares in its own
  `etc/simva.d/simva-env.sh`. It is merged from the base file plus a `development` or
  `production` variant (and sometimes a version-specific file).
- **Phase** — an operation on the lifecycle: `install`, `start`, `stop`, `backup`, `restore`,
  `purge`, `uninstall`, `upgrade`, `migrate`, `migrate_db`, `changeConfig`, `migrateDomain`.
  Hooks are scripts that run before and after a phase.
- **External domain** — the public DNS suffix (`SIMVA_EXTERNAL_DOMAIN`, default
  `external.test`). Every service is reached as `https://<subdomain>.<external-domain>`.
- **SIMVA_ENVIRONMENT** — `development` or `production`. It selects which compose variants and
  which development-only services are started.
- **Marker** — a plain file under `data/<stack>/` (`<stack>/.initialized`, `/.version`,
  `/.externaldomain`) that lets the script decide whether a stack needs installing,
  upgrading, or domain migration.

The external domain, the subdomains, the versions and the passwords all come from two
environment files, read — not committed — at runtime:
`docker-stacks/etc/simva.d/simva-env.sh` and `.../simva-env.dev.sh`.

## Where the real history is

The deployed branches (e.g. `rustfs`) are shallow snapshots created by
`change-branch-simva-infra.sh`. The project's full history — 669 commits back to April 2020 —
is reachable from the release tags (`v0.0.1`, `v0.1.0`, `v0.1.1`, `v2.0.0-alpha`). The
[decisions](./explanation/decisions/README.md) section is written from that history.