# ADR-0010 — Extensions are pulled, not built from source

- **Status:** Accepted
- **Date:** 2025-03-05 → 2025-03-07

## Context

Keycloak ran with locally built extensions (custom event listeners, mail spools) whose
source lived inside the SIMVA repo — and Kafka's connectors were built from the same kind of
vendored source. Every upgrade pulled that compile chain into the stack: source checkouts,
Maven/Gradle builds, extension jars injected at container start. The build was slow,
fragile (Java toolchain drift), and it coupled SIMVA's release cadence to whatever the
extension source had happened to become.

## Decision

The stacks **pull prebuilt artifacts** instead of building from source:

- `c9904ec` (2025-03-05) added a script to **pull the Keycloak extensions** as released
  jars; `f734077` (2025-03-07) **removed the Keycloak extensions source** from the repo.
- `8e33dc1` (2025-03-07) switched Kafka's sink to **pull instead of build** the connector.

The compose files reference images and released jars; hooks that used to compile now
download (and, where needed, verify checksums) then drop the artifact into the container
path. The scripts that remain are downloaders, not compilers.

## Consequences

**Positive**

- Stacks boot from released artifacts; a stack is reproducible from a version list, not from
  whatever source was vendored.
- Install time and failure modes drop by a build.
- SIMVA stops being the bearer of the extensions' licenses and toolchains.

**Negative**

- **The extension must exist upstream at the exact version pinned.** A version bump that a
  maintainer has not published yet blocks the stack (hence the download scripting, which
  surfaces "404" early).
- **Extending an extension now means forking upstream and republishing** — a workflow
  change for the teams that used to patch in-repo.
- Version alignment between the extension's release and the Keycloak/Kafka version became a
  coordination task, not a compilation side-effect.

## Evidence

- `c9904ec` (2025-03-05) — script to pull keycloak extensions
- `8e33dc1` (2025-03-07) — pull instead of build kafka extensions
- `f734077` (2025-03-07) — remove keycloak extensions code from simva infra

## Related

- [Reference: stacks](../../reference/stacks.md) — version-family compose selection
- [ADR-0009](0009-upgrades-are-replayed-in-order.md) — versions are now the only way an
  extension reaches a stack