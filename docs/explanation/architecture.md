# Architecture

SIMVA is a *deployment script plus declarative stacks*: twelve numbered folders under
`docker-stacks/`, a single controlling Bash script, and a strict separation between what is
committed (code, templates, fragments) and what is generated (configuration, state, backups).

## The layers, read top to bottom

```text
simva-infra/
├── docker-stacks/                     ← the whole runtime lives here
│   ├── simva                          ← the one script that owns the lifecycle
│   ├── bin/                           ← helpers hooks call (wait, backup-restore, volumectl)
│   ├── etc/
│   │   ├── simva.install.d/simva-env.sh   ← SIMVA_STACKS order, *_HOME dirs, wait-times
│   │   └── simva.d/{simva-env.sh, simva-env.dev.sh} ← instance config (untracked, from *.example.sh)
│   ├── config-template/               ← gomplate templates (committed)
│   ├── config/                        ← generated config; gitignored except placeholders
│   ├── data/                          ← runtime state + markers; gitignored
│   └── backup/                        ← dumps; gitignored
│       └── NN-name/
│           ├── docker-compose*.yml    ← a stack RESTATES DELIBERATELY simple
│           └── etc/simva.d/simva-env.sh
└── docs/                              ← this documentation
```

The layers in order of *invocation*, which is also the order of dependency:

1. **`00-network`** — creates the shared named bridge out of nothing.
2. **`01-traefik`** — the only public face; everything else is reachable only through it
   and only inside the bridge.
3. **`09-logs`** — observability that the *other* stacks lean on while they boot.
4. **`02-keycloak` … `11-lrs`** — the service stacks, in dependency order:
   authentication before the apps that use it; storage and messaging between them; SIMVA in
   the middle; TMon and PUMVA on top.
5. The comma-shaped exceptions (`09-logs`, `11-lrs`, `10-pumva`) exist because the numbering
   expresses *dependency depth* (how far down the graph a stack sits), not pure chronological
   order. `SIMVA_STACKS` keeps them in the one correct boot sequence.

## Three control planes

Everything the script does decomposes into one of these:

1. **Compose plane** — `docker compose` invocations driven by `COMPOSE_FILE`, which each
   stack builds from its own fragments (`base + dev/prod + version + markers`).
2. **Hook plane** — per-stack Bash scripts around every lifecycle event
   ([reference/hooks.md](../reference/hooks.md)). This is where container-adjacent work
   happens and where the compute convention is *idempotent and numbered*.
3. **Marker plane** — plain files in `data/<stack>/` (`.initialized`, `.version`,
   `.externaldomain`, `sqlite_init`) that the script reads to *decide* between
   install / upgrade / migrate-domain / start. Markers are the memory of the machine.

## The one script

`docker-stacks/simva` is a 1500-line Bash program whose `main` dispatches twelve operations
to functions of the same name. The unglamorous part is the part that matters: it sources the
*right* environment fragment before every stack, exports a consistent hook environment, and
backs up before anything that could be regretted. There is barely any logic worth
documenting beyond that — the repository is mostly *declarations* (compose files, versions,
templates) and *state machines* (markers → decisions).

## What is deliberately not there

- **No docker-compose-one-file-to-rule-them-all.** Each stack is self-contained
  ([ADR-0002](./decisions/0002-stacks-declare-their-own-compose.md)); merging happens at
  runtime by `COMPOSE_FILE`.
- **No committed configuration.** `config/`, `data/` and `backup/` are host-owned
  ([ADR-0006](./decisions/0006-instance-config-is-hosted-not-committed.md)).
- **No hand-edited container files.** Everything inside a container is either pasted in from
  a hook or rendered at start time by gomplate from `config-template/`.

## See also

- [reference/stacks.md](../reference/stacks.md) — each stack, its services and its selection
- [configuration-and-state.md](./configuration-and-state.md) — the generated-vs-committed split
- [decisions/](./decisions/README.md) — how this architecture was chosen, one record at a time