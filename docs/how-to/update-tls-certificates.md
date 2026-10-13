# Update TLS certificates

SIMVA fronts every service with Traefik, and Traefik presents a **wildcard certificate** for
your external domain. The certificate material, the truststore for the internal TLS, and the
DH parameters all live under `config/tls/` (see
[reference/environment-variables.md](../reference/environment-variables.md) for the file
names). Two regimes exist, chosen by `SIMVA_TLS_GENERATE_SELF_SIGNED`:

- `false` — you supply a real CA's wildcard certificate; SIMVA stops Traefik if it is about
  to expire.
- `true` — SIMVA generates its own root CA with `mkcert` and signs everything from it
  (the tutorial's behaviour).

## Providing or refreshing a real certificate

Place the three files from your CA one level above the deployment folder — the same place
as `simva-infra/` — or two levels above `docker-stacks/`. The names are derived from the
domain:

```bash
# for SIMVA_EXTERNAL_DOMAIN="simva.my-university.org"
/opt/infra/simva-infra/../../simva.my-university.org.pem            # root CA
/opt/infra/simva-infra/../../simva.my-university.org-privkey.pem    # private key
/opt/infra/simva-infra/../../simva.my-university.org-fullchain.pem  # full chain
```

If Shlink runs on its own domain (`SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN=false`), provide
the same triple for `SIMVA_SHLINK_EXTERNAL_DOMAIN` too.

Then:

```bash
cd docker-stacks && sudo su
./simva updatecerts
```

What happens, mechanically:

1. `bin/update-certs.sh` checks the root CA with `openssl x509 -checkend 0` — an expired CA
   means an error and a **refusal to start** until you replace it.
2. It copies `<domain>.pem` → `config/tls/traefik.pem`, `-privkey.pem` → `traefik-key.pem`
   and `-fullchain.pem` → `traefik-fullchain.pem` (and the matching Shlink trio).
3. On `./simva start`, `01-traefik/etc/hooks/before-start.d/00-check-rootCA.sh` re-checks,
   and `10-configure-traefik.sh` regenerates `config/traefik/traefik/static-conf/traefik.toml`
   from the template with the new certificate paths and the HTTP→HTTPS redirect.

## Refreshing the self-signed regime

The one-off generation is `01-traefik/etc/hooks/before-install.d/10-create-wildcard-certificate.sh`:

1. `mkcert -install` creates/keeps a root CA under `config/tls/ca/` (`SIMVA_ROOT_CA`), with a
   `backup/` subfolder,
2. the helpers build the wildcard cert, the fullchain, the Keycloak `.p12`
   (`SIMVA_KEYCLOAK_TLS_TRUST_STORE`, used by the SSO), the `truststore.jks` and
   `dhparam.pem`.

To regenerate, delete the CA pieces and re-run start (or `install`):

```bash
./simva stop 01-traefik/
rm -rf config/tls/ca
./simva start 01-traefik/
```

The hooks are idempotent: `00-check-rootCA.sh` and helpers skip work that already exists, so
the remove-and-recreate cycle is how you force a new self-signed chain.

## Checking a certificate

```bash
docker-stacks/bin/check-certificate-valid.sh config/tls/traefik.pem
```

exits 0 when not yet expired and prints the `NotAfter` date. That is the same check the
startup hooks run, so "it passed locally" and "it passed on `./simva start`" are the same
test.

## See also

- [networking-and-tls](../explanation/networking-and-tls.md) — why the certificates are
  host-side and mounted read-only into Traefik and Keycloak
- [reference/hooks.md](../reference/hooks.md) — every `01-traefik` hook in the chain