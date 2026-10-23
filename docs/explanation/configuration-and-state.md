# Configuration and state

SIMVA draws one clean line that explains almost everything: **code and templates are
committed; configuration and state are not.** Everything that differs between two instances
of SIMVA — domains, ports, passwords, generated certificates, realm exports, which services
are up — flows through three mechanisms that obey the line.

## 1. Configuration = environment

There is no `config.yml` and no per-container `.env` that a human edits after
installation. The instance's whole configuration is the exported **Bash environment**, whose
defaults live in committed fragments:

- `etc/simva.install.d/simva-env.sh` — *shape*: `SIMVA_STACKS`, the `SIMVA_*_HOME`
  directories, wait-time constants, the building blocks every other fragment derives from.
- `etc/simva.d/simva-env.sh` — *instance identity and values*: domain, network, versions,
  credentials. **Not committed** (it holds secrets): it is generated from the tracked
  `simva-env.example.sh` template, see [manage-env-secrets](../how-to/manage-env-secrets.md). Editing this file is the canonical way to reconfigure (and the file the
  upgrading/migrating machinery re-reads to detect drift).
- `etc/simva.d/simva-env.dev.sh` — *development-only* values, deliberately kept out of the
  production path (git refs, dev subdomains, `SIMVA_DEVELOPMENT_LOCAL`). Also untracked,
  generated from `simva-env.dev.example.sh`.
- `<stack>/etc/simva.d/simva-env.sh` — *selection*: the `COMPOSE_FILE` merge for that stack.
- `config/<stack>/simva-env.sh` — a *generated* override file: hooks render it so that later
  phases of the same boot read what they themselves produced.

Why environment variables? Because it is the transport that Docker Compose, gomplate
templates, hooks and containered entrypoints all already read — one variable flows into a
compose `environment:`, a `config-template/traefik/traefik.toml.gtmpl` substitution, a
`before-start.d` script and a JVM `-D` flag with zero conversion code. It also makes every
reconfiguration **replayable**: the same env export list on a fresh clone yields the same
instance.

## 2. Generated files = rendered at boot

Template → file translation happens in hooks, per stack, using the vendored `bin/gomplate`:

```text
config-template/traefik/traefik/static-conf/traefik.toml  ──>  config/traefik/traefik/static-conf/traefik.toml
config-template/keycloak/...                              ──>  config/keycloak/...
```

The templates are committed (they are the *code* of the generated config); the outputs under
`config/` are gitignored except `.gitignore` placeholders. That is the second, arguably more
important sense of "configuration is not committed": **no two boots can accidentally serve a
stale checked-in config**, because the boot renders it anew from current variables.

## 3. State = markers + named volumes

Docker compose owns the containers; SIMVA needs *decided state* — has this stack been
initialized, which version is installed, which domain was it for — to decide the next
`start`'s behaviour. That state is written as plain dot-files under `data/<stack>/`:

| Marker | Decision it feeds |
| --- | --- |
| `.initialized` | fresh install vs normal start |
| `.version` | upgrade detection (compare to `SIMVA_<STACK>_VERSION`) |
| `.externaldomain` | domain-migration detection |
| `.downloded` / custom per-stack flags | whether a first-run download already happened |

Containers' durable *byte* state lives in **named volumes** (`minio_data`, `simva_sqlite_data`,
`kc_maria_db_data`, `pgdata`, …), declared in each stack's compose. Named volumes are the
reason `stop`/`uninstall` are non-destructive and the reason `backup` has to be a **hook**
activity: the bytes are not on the host filesystem, so only a container-side dump (realm
export, mysqldump, bucket archive) can move them into `backup/<stack>/`.

The markers, the generated config and the volumes jointly define what a "SIMVA instance" is;
the `change-branch-simva-infra.sh` deployment model exists precisely to move the *committed*
part from branch to branch while leaving the *generated/state* part (data, config, backup,
etc) untouched.

## The three-way split, one table

| Read during boot | Committed? | Written by | Backup covers it |
| --- | :-: | --- | :-: |
| `etc/simva.install.d/simva-env*.sh`, `etc/simva.install.d/simva-env*.example.sh` | yes | you |
| `etc/simva.d/simva-env.sh`, `simva-env.dev.sh` | no (secrets) | you / synced from the templates |
| other `etc/*/simva-env*.sh` | yes | you | (separately — back it up yourself) |
| `config-template/` | yes | you | — |
| `config/*/` (generated) | no | hooks, via gomplate | yes (`config/` copy) |
| `data/*/` markers | no | the machinery / hooks | yes (inside `datafiles`) |
| named volumes | no | containers | yes, only via backup hooks |
| `backup/*/` | no | `./simva backup` | — (it *is* the backup) |

## See also

- [decisions/0006-instance-config-is-hosted-not-committed.md](./decisions/0006-instance-config-is-hosted-not-committed.md)
- [reference/environment-variables.md](../reference/environment-variables.md)
- [reference/hooks.md](../reference/hooks.md)