# Change the external domain

Every published service is reachable as `https://<subdomain>.<external-domain>`. Moving an
environment to a different suffix — from `external.test` to
`your-institution.example.org` — is a first-class, scripted operation, because certificates,
Keycloak realm, LimeSurvey SAML, MinIO buckets and the SIMVA API all embed the domain.

## Before you start

- You must be **root** inside `docker-stacks/`.
- The new domain's wildcard certificate material must exist, *unless* you keep
  `SIMVA_TLS_GENERATE_SELF_SIGNED="true"`.
- Plan the host names: see [update-tls-certificates.md](./update-tls-certificates.md) for
  how SIMVA stores `.pem` files for the domain you choose.

## Steps

1. Edit `etc/simva.d/simva-env.sh`:

   ```bash
   export SIMVA_EXTERNAL_DOMAIN="simva.my-university.org"
   ```

2. If Shlink should live on a different suffix than the rest (some institutions want the
   shortened URLs on their own domain), also set:

   ```bash
   export SIMVA_SHLINK_EXTERNAL_DOMAIN="s.my-university.org"
   ```

3. Update DNS and local hosts files so every subdomain resolves to the host.

4. Start:

   ```bash
   ./simva start
   ```

## What `start` does about it

`sima start` compares the external domain it was given against the value recorded on disk in
each `data/<stack>/.externaldomain`. When they differ, it follows the same scripted sequence
the version checks use, stack by stack:

```text
A new external domain has been detected in simva-env.sh for stack <stack>.
A backup of your data is advised before migrate domain.
A backup of your data will be done automatically before migrate domain.
Are you sure you want to migrate to this external domain ? (Y/N):
```

Answering `y` triggers, per stack:

1. an automatic `backup`,
2. the `migrate` hooks (`before-migrate.d`, `after-migrate.d`) and the domain hooks
   (`before-migrateDomain.d`, `after-migrateDomain.d`),
3. the Keycloak, LimeSurvey and MinIO hooks that rewrite their configuration with the new
   host names,
4. a fresh `install` of that stack's images, then `start`, then `stop`,
5. `data/<stack>/.externaldomain` rewritten to the new value.

The confirmation prompt is asked once per run; answering once ("yes"/"y") covers every stack.

## Rollback

The migration backs up before touching anything. To go back to `external.test`:

```bash
# set SIMVA_EXTERNAL_DOMAIN back
./simva restore 01-traefik/
./simva start
```

Restoring is preferable to re-running `start`, because the markers on disk would otherwise
still say you already migrated.