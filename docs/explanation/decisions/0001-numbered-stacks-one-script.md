# ADR-0001 — The environment is numbered stacks driven by one script

- **Status:** Accepted
- **Date:** 2020-06-11 → 2020-09-17

## Context

The original `simva-infra` ("Initial version of the environment", 2020-06-11) was a single
`simva` script and a `distribution/` of folders with no ordering contract. As Keycloak,
Limesurvey and MinIO each grew from one being into their own configuration, credential and
startup logic, two problems appeared: the launch order became implicit (boot Keycloak before
Limesurvey, or the survey cannot resolve its SSO), and operating one component required
knowing which of several ad-hoc scripts owned it.

## Decision

Structure the runtime as **twelve numbered stacks** described by one central list,
`SIMVA_STACKS` in `etc/simva.install.d/simva-env.sh`:

```text
00-network  01-traefik  09-logs  02-keycloak  03-limesurvey  04-minio
05-kafka  06-shlink  11-lrs  07-simva  08-tmon  10-pumva
```

The number is a dependency depth, not an identity: `start` walks the list forward and `stop`
walks it backward, and each stack is brought up only after every stack whose readiness it
needs. A single executable, `docker-stacks/simva`, dispatches every operation; the decision
of which subset to operate on is a per-invocation argument (the script gained the ability to
manage stacks individually in 2020-09-17 rather than always operating the whole set).

Two things followed that are easy to mistake for accidents: stacks at the same depth with
later numbers (the `09-logs` observability stack, `10-pumva`, `11-lrs`) still boot in the
order that their real dependencies dictate, and `00-network` exists purely so network
creation has a *host* in the list.

## Consequences

**Positive**

- The launch order is a list you can read and reorder.
- Operations become per-stack: `./simva backup 02-keycloak/` is the same machinery as a full
  backup.
- Reversing the list for teardown gives a safe shutdown and, with `down -v`, a safe
  uninstall.

**Negative**

- **The numbering is only as correct as the people who edit it.** Nothing validates that
  `10-pumva` does not need `11-lrs` before it boots; the wait hooks are the safety net.
- **The whole-set default is surprising.** A bare `./simva start` is a full environment; an
  operator who wanted one stack must remember the argument.

## Evidence

- `a3edcf0` — 2020-06-11, initial version of the environment
- `85bbe2a`, `da67a91`, `c2ea4fe`, `9c18856`, `e307c75` — 2020-06/07, per-stack
  "make it configurable" restructurings that demanded the ordering contract
- `9df4f6e`, `140d593` — 2020-07-13/16, distribution directory restructure and "moving
  stacks to proper location"
- `7717dbb` — 2020-09-17, "Update simva command to manage the stacks individually"

## Related

- [Architecture](../architecture.md)
- [Reference: stacks](../../reference/stacks.md)
- [ADR-0002](0002-stacks-declare-their-own-compose.md) — what one stack folder contains