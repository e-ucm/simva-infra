# ADR-0006 — Instance configuration is hosted, not committed

- **Status:** Accepted, with a caveat
- **Date:** 2020-10-01 → 2025-12-02

## Context

Early on, instance-specific values — domains, passwords, which Git ref to build — lived
inline in compose files or in checked-in env files shared by every deployment. Two pressures
collided: the repo is also a template that people deploy untouched (`git clone && start`
should not require pre-editing a dozen files), and development needs values production must
not carry (debug subdomains, `SIMVA_DEVELOPMENT_LOCAL`).

`413b7da` (2020-10-01) set the naming convention by renaming and **exporting project-wide
environment variables**, and `37a4d2e` (2020-07-17) had established the pattern of one
shared variable (`SIMVA__SSO_OPENID_CONFIG_URL`) consumed by several stacks.

## Decision

Configuration is the exported Bash environment, defined in committed fragments that are
sourced, not substituted:

- `etc/simva.install.d/simva-env.sh` — shape of the project (`SIMVA_STACKS`, the
  `SIMVA_*_HOME` directories, wait-times);
- `etc/simva.d/simva-env.sh` — instance identity and values (domain, network, versions,
  credentials); untracked, generated from `simva-env.example.sh` (see
  [manage-env-secrets](../../how-to/manage-env-secrets.md));
- `etc/simva.d/simva-env.dev.sh` — development-only values, added 2025-01-08 and corrected
  2025-12-02 so it is loaded **only in development**;
- `<stack>/etc/simva.d/simva-env.sh` — per-stack `COMPOSE_FILE` selection.

Generated config (certificates, realm exports, rendered templates) goes to `config/`
(untracked), runtime state to `data/` (untracked). The clone stays throwaway; the instance
configuration is not in it. Committed secrets are avoided by design: commented password
lines mean "the hook generates one at first install and stores it under
`config/container-tools/`".

## Consequences

**Positive**

- A deployment is `source the right fragment` away from any topology; the same clone can
  become `external.test` or `simva.university.org` by editing two lines.
- Dev and prod never share values: the dev file is only ever loaded in development.
- Reconfiguration is replayable — the env list *is* the instance spec.

**Negative**

- **Passwords default to `password`.** The template's default credential block is committed
  with well-known values; "TO MODIFY" is a comment, not enforcement. Every deployment must
  change them or be logged into.
- **The dev/prod split leaked.** Committed-but-not-gitignored generated files under
  `config/container-tools/` can accidentally carry generated secrets onto the branch; the
  line between "config is not committed" and "some config is" is drawn by `.gitignore`, not
  by the design.
- **Editing env files requires a full `start` to take effect**; there is no hot reload, and
  the upgrade/domain machinery re-reads these files, so an accidental edit is *acted on*.

## Evidence

- `413b7da` (2020-10-01) — rename/export of project environment variables
- `37a4d2e` (2020-07-17) — a shared OpenID config variable consumed by the whole SSO
- `bdc7fc2` (2025-01-08) — "adding SHLINK variable domain + simva env dev created launched
  only on development"
- `2c8d1e2` (2025-12-02) — "fix install.d for simva env dev file separated"

## Related

- [Configuration and state](../configuration-and-state.md)
- [Reference: environment variables](../../reference/environment-variables.md)
- [Expression of the trade-off in the docs index](../../index.md#where-the-real-history-is)