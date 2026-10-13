# Networking and TLS

SIMVA's network design is one sentence: **one bridge, one entrypoint, everything else is a
guest on it.** Layer the consequences on top and most of the infrastructure's behaviour — and
its security posture — falls out.

## One bridge

`SIMVA_SERVICE_NETWORK` is a single Docker **named bridge network** called
`traefik_services`, created by the `00-network` stack on a dedicated host interface
`simva0` with a fixed private subnet (`172.30.0.0/24`). Every service container of every
stack attaches to it. Consequences:

- Any container can reach any other container by its compose service name or by
  `<subdomain>.${SIMVA_INTERNAL_DOMAIN}` hostnames — no `--link`, no published ports, no
  inter-container secrets in the clear.
- The subnet and interface are **fixed numbers on the host** (`SIMVA_NETWORK_CIDR`,
  `SIMVA_NETWORK_INTERFACE`): the VM's `/etc/hosts`, Docker port forwards and firewall rules
  all operate on a predictable, stable address space instead of random bridge numbers.
- Only the Katka family and the LRS side-car networks (`kafka_services`, `traefik_admin`)
  are extra; the rule "everything on the one bridge" holds for the service graph itself.

## One entrypoint

Nothing else publishes a port. The lone public listener is Traefik on `0.0.0.0:80/443`
(host ports 8080/8443 in the Vagrant VM). Traefik routes by Host header — every service has
a subdomain of `SIMVA_EXTERNAL_DOMAIN` registered in its compose labels — terminates TLS
with the wildcard certificate, and forwards (reverses) into the bridge.

The second door to the Docker API also deserves emphasis: Traefik does **not** mount
`/var/run/docker.sock`. The `tecnativa/docker-socket-proxy` container does, and Traefik talks
to **that** proxy. The proxy answers only the HTTP API verbs Dockerfile's labels need
(container list, create/update for the frontend, health). Mounting the raw socket into the
public edge would hand a namespace-root pipe to anyone who could reach the dashboard; the
proxy is the visible substitute. The switch is one paragraph of compose config, and it costs
nothing in feature surface because Traefik's dynamic config does not need it.

## TLS: host-owned material, mounted read-only

Certificates and keys live **on the host** under `config/tls/` and are mounted into Traefik
and Keycloak read-only. SIMVA never manages a CA inside a container. Two regimes:

- `SIMVA_TLS_GENERATE_SELF_SIGNED="false"` — the operator's real wildcard chain
  (`<domain>.pem`, `-privkey.pem`, `-fullchain.pem`) sits one level above the repo;
  `./simva updatecerts` copies it into `config/tls/`, expiry-checked. This is the
  deployment default because sessions are served to browsers that must not warn.
- `"true"` — `mkcert -install` creates a local root CA under `config/tls/ca/` and the
  before-install hooks sign the wildcard from it; extra entries
  (`keycloak.p12`, `truststore.jks`, `dhparam.pem`) are derived from the same material and
  mounted into the SSO.

Because Keycloak peers over TLS too, the hooks generate a **truststore** (`truststore.jks`,
alias `simvaCA`) that the identity provider uses both inward (its own certificate) and
outward (validating the Traefik/nginx certs of the services it OAuth-redirects to).
Regeneration is a host-side action (see
[update-tls-certificates.md](../how-to/update-tls-certificates.md)); containers never
regenerate it.

## The HTTP→HTTPS promise

By default Traefik rewrites `→ https` permanently. The load-balancer knobs
(`SIMVA_LOAD_BALANCER`, `SIMVA_DEV_LOAD_BALANCER`) exist for the case where a real LB
terminates TLS *in front of* Traefik and must not get looped back to port 80 by a redirect.

## Internal vs external names

Everything *inside* the bridge is addressed as `<subdomain>.internal.test`; everything
*a browser can reach* is `<subdomain>.external.test`. The gap between the two is what
Traefik's label routing spans, which is also why changing the external domain is a
scripted, backed-up, whole-system event rather than a DNS edit.

## See also

- [decisions/0004-a-shared-external-network.md](./decisions/0004-a-shared-external-network.md)
- [decisions/0005-traefik-fronts-everything.md](./decisions/0005-traefik-fronts-everything.md)
- [how-to/update-tls-certificates.md](../how-to/update-tls-certificates.md)