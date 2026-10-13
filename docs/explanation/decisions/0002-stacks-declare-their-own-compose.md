# ADR-0002 — Each stack declares its own compose file set

- **Status:** Accepted
- **Date:** 2020-06-30 → 2020-07-16

## Context

The first restructurings (2020-06/07) pushed shared concerns — TLS, credentials, SAML — into
each service's compose file until the files grew long and began duplicating one another.
Adding a *development* variant or a *version* variant meant editing every file at once, and
the `simva` script had to know the composition rules by heart to know what it was starting.

## Decision

Each stack is self-contained: its folder owns its base `docker-compose.yml`, the variants
(`docker-compose.dev.yml`, `docker-compose.prod.yml`, version-specific files like
`docker-compose-keycloak-version-sup-26.yml`), and a Bash fragment,
`<stack>/etc/simva.d/simva-env.sh`, that decides the runtime value of a single exported
variable:

```bash
export COMPOSE_FILE="docker-compose.yml"
export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"     # environment
export COMPOSE_FILE="$COMPOSE_FILE:docker-compose-keycloak-version-sup-26.yml"   # version
```

Everything downstream — `docker compose up`, hooks, `wait-available` — reads the one merged
value and needs to know nothing about *why* that particular merge happened. Merging happens
at runtime from *committed* files; no compose file is generated into `config/`.

## Consequences

**Positive**

- A stack's surface is exactly its folder. Reading `07-simva/etc/simva.d/simva-env.sh` tells
  you which backend it will run today.
- Variants stay thin: the base file holds the service, the variants only override.
- The script's compose logic stays a one-liner (`docker compose -f merge up`) per stack.

**Negative**

- **The merge rules are Bash, not compose.** A stack whose selection logic is intricate
  (MinIO's marker-based FS/XL/RustFS choice, SIMVA's database markers) is hard for a
  non-shell reader to parse — those fragments are now the longest in the repo.
- **Ordering inside a merge is fragile.** Later files override earlier ones; getting the
  merge string wrong silently drops an override rather than failing loudly.

## Evidence

- `85bbe2a` (2020-06-30), `da67a91` (2020-07-01), `c2ea4fe` (2020-07-03), `9c18856`
  (2020-07-06) — the per-stack "make it configurable" restructurings
- `e307c75` (2020-07-16) — Kafka stack added on the same pattern
- `2c8d1e2` (2025-12-02) and the `*version*.yml` files — the pattern extended to versions
  and to a separated dev env

## Related

- [Reference: stacks](../../reference/stacks.md)
- [ADR-0001](0001-numbered-stacks-one-script.md) — the stacks these folders belong to
- [ADR-0009](0009-upgrades-are-replayed-in-order.md) — version files are also chosen here