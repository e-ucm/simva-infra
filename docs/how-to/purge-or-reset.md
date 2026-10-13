# Purge or reset an environment

Two commands dismantle an environment. The safe one leaves your data on disk; the
destructive one removes not only containers and volumes but the generated configuration
and the per-stack data folders too.

| Command | Containers + networks | Named volumes | `config/<stack>/` | `data/<stack>/` |
| --- | :-: | :-: | :-: | :-: |
| `./simva stop` | down (containers only) | kept | kept | kept |
| `./simva uninstall` | down `-v` (deleted) | deleted | kept | kept |
| `./simva purge` | down `-v` | deleted | removed | removed |

## Uninstall — take the containers away, keep your state

```bash
./simva uninstall              # all stacks, in reverse order
./simva uninstall 07-simva/    # just SIMVA
```

Per stack this runs `before-uninstall.d` hooks, `docker compose down -v` (which deletes the
named volumes), then `after-uninstall.d` hooks. Because `config/` and `data/` are untouched,
the *next* `./simva start` is a normal start: every `.initialized` and `.version` marker is
still there, so no stack is re-created from scratch.

## Purge — remove all byte-level state, but keep the code

```bash
./simva purge
```

This is uninstall plus the `purge.d` hooks, which are the ones that delete the on-disk
per-stack folders (`01-remove-data-and-config.sh` in most stacks):

- `config/<stack>/` — the generated certificates, realm exports, SAML config,
- `data/<stack>/` — the checkout/markers/templates folders.

What survives: nothing except the repository itself and `SIMVA_STACKS`'s compose files. The
next `./simva start` therefore behaves exactly like a fresh clone: first-run downloads,
`install` hooks, certificate generation and all.

## The reset drill (nuclear option)

When you want a *pristine* environment identical to a fresh `v2.0.0-alpha` clone:

```bash
./simva purge
rm -rf config data backup
./simva start
```

`config` and `data` currently keep only `.gitignore`-style placeholders in git, so deleting
them is safe; the backups you produce afterwards land in a fresh `backup/` tree.

## The gentle branch change (deployment model)

Deployments switch whole branches rather than mutate a live instance. The include
`change-branch-simva-infra.sh` model from the repository root:

```bash
# rsync only the tracked tree, excluding every instance-owned directory
rsync -av --exclude data/ --exclude config/ --exclude backup/ --exclude etc/ ... /path/to/new-branch/
```

After the sync, run `./simva install` on the target so its `install.d` hooks set up the new
layout. Your markers and data ride along untouched, because none of the excluded folders
changed.

## Before you pull the trigger

- Automatic backups happen before *upgrades and domain changes*, never before purge. If you
  want the data, run `./simva backup` first — the `backup/` tree is the intended recovery
  point for anything this section destroys.
- Purge is per-stack too: `./simva purge 02-keycloak/` wipes only Keycloak's `config/` and
  `data/`. Use this to fix a stack whose generated state is corrupted, then `./simva start`
  rebuilds just it.

## See also

- [reference/cli.md](../reference/cli.md) — every command's exact semantics
- [reference/hooks.md](../reference/hooks.md) — the `purge.d`/`uninstall.d` hook chains
- [explanation/decisions/0008-backups-run-before-destructive-ops.md](../explanation/decisions/0008-backups-run-before-destructive-ops.md)