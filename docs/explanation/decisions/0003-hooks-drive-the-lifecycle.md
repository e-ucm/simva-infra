# ADR-0003 — Docker runs containers; hooks run everything else

- **Status:** Accepted
- **Date:** 2020-07-13

## Context

By mid-2020 the stacks had grown container-adjacent work that compose cannot do and should
not: exporting a Keycloak realm, writing SAML service-provider keys, installing certificate
chains into a truststore, waiting for a service to answer, deciding whether a first install
needs a longer budget. This logic had been scattered inside the `simva` script and inside
compose entrypoints, which meant a change to "how one stack initializes" required editing
the orchestration script *and* container images, and the two could drift.

## Decision

The lifecycle becomes a **hook cascade**. Around every phase of a stack —
`install`, `start`, `stop`, `backup`, `restore`, `uninstall`, `purge`, `upgrade`, `migrate`,
`migrateDomain`, `migrate_db`, `changeConfig` — the script runs every executable in
`<stack>/etc/hooks/before-<phase>.d/` and (`after-<phase>.d` | `purge.d` | `restore.d` |
`backup.d`), in filename order, plus the same folders at the top level for global actions.
Each run is given a stable environment (`CURRENT_STACK`, `STACK_NAME`, `STACK_HOME`,
`STACK_CONF`, `HELPERS_STACK_HOME`, the stack's own `bin/` on `PATH`, and its `COMPOSE_FILE`),
and the stack's helper shell libraries live in `<stack>/etc/hooks/helpers.d/`.

`docker-stacks/07-simva/etc/hooks/` is the canonical exhibit: `before-start.d` decides
SQLite versus MongoDB via markers, `after-start.d` waits for a migration fleet and flips the
marker when it finishes, `backup.d` dumps the live volume. Compose only ever *runs the
containers*; hooks own the moments around it.

## Consequences

**Positive**

- Container-adjacent logic finally has a home that ships with the stack it configures.
- Numbered filenames give an explicit ordering contract inside each phase.
- The script stays a thin dispatcher; hooks carry the real state transitions.

**Negative**

- **Hooks are Bash and run as root on the host.** A mistake in a hook can touch the host
  machine, so the code-review surface is the shell scripts, not the compose file.
- **Idempotency is a discipline, not a guarantee.** Nothing forces a hook to be
  re-runnable, and several had to grow guard blocks (marker checks) to be safe on repeat
  starts.

## Evidence

- `b496a33` (2020-07-13) — "Adding kafka management hooks"
- `d5fb8bf` (2020-07-13) — "Adding traefik management hooks"
- The whole `*/etc/hooks/` tree, before/after pairs per phase

## Related

- [Reference: hooks](../../reference/hooks.md)
- [ADR-0001](0001-numbered-stacks-one-script.md) — the phases hooks attach to
- [ADR-0004](0004-a-shared-external-network.md) — network setup was the first thing hooks
  replaced