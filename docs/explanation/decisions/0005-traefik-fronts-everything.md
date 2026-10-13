# ADR-0005 — Traefik fronts every published service over HTTPS

- **Status:** Accepted
- **Date:** 2020-10-02 → 2020-10-14

## Context

Until October 2020, SIMVA reached its front end on the base URL and each service on its own
exposed port with plain HTTP on the outside. Sessions are published to browsers; the browser
chose the URLs, so changing the entry host later meant re-adding every service. Two commits
in October 2020 changed the shape of the whole product: moving the SIMVA front end back to
the **base domain** (no port, no path), and then serving the front end and "other services"
**through https + traefik**.

## Decision

Traefik is the single reverse proxy and the **only published listener**: `:80/:443` (host
ports 8080/8443 in the Vagrant VM). Every service registers itself by label on a subdomain
of `SIMVA_EXTERNAL_DOMAIN`; Traefik routes on the Host header, terminates TLS with the
wildcard certificate mounted from `config/tls/`, and proxies into the shared bridge. The
default policy is a permanent HTTP→HTTPS redirect unless a real load balancer precedes
SIMVA (`SIMVA_LOAD_BALANCER` / `SIMVA_DEV_LOAD_BALANCER`).

The proxy does **not** mount the Docker socket. The `tecnativa/docker-socket-proxy`
container mounts `/var/run/docker.sock` and answers only the HTTP API subset Traefik's
label-discovery needs; Traefik talks to the proxy. Mounting the raw socket into the public
edge would expose the Docker API to anything that reached the proxy at all.

## Consequences

**Positive**

- One port pair to open/forward, one certificate, one termination point.
- Every published service has a stable `https://<subdomain>.<external-domain>` URL; the
  front end reclaimed the base domain.
- The socket proxy is the security boundary between the internet-facing process and the
  Docker API — a design later mirrored in how Keycloak/nginx peers are trusted.

**Negative**

- **Traefik is now load-bearing infrastructure.** A mis-edited `traefik.toml` (rendered by
  gomplate from `config-template/`) takes every service down at once.
- **The wildcard certificate is a single point of expiry.** A root CA that lapses gates
  *all* HTTPS (the `updatecerts`/`check-rootCA` hooks exist specifically because of this).
- **Developers must remember devices' hostnames**: subdomain-routed access means `/etc/hosts`
  needs each subdomain you actually visit.

## Evidence

- `4f2bb9f` (2020-10-02) — "moving simva to the base domain"
- `a3cf038` (2020-10-14) — "Access through https+traefik"
- `e863576` (2020-10-14) — "Access other services through https + traefik"
- `01-traefik/docker-compose.yml` today — socket-proxy + `traefik:2.11.3`

## Related

- [Networking and TLS](../networking-and-tls.md)
- [How-to: update TLS certificates](../../how-to/update-tls-certificates.md)
- [ADR-0004](0004-a-shared-external-network.md) — the bridge this proxy fronts