# ADR-0004 — One shared, configurable external network for every service

- **Status:** Accepted
- **Date:** 2020-06-24

## Context

At day one, each stack created its own bridge network with Docker's default random subnet,
and services that had to talk reached each other by `docker run --link`-style conventions or
published ports. Two failures were immediate: **nothing guaranteed a fixed address space**
(the host firewall, the Vagrant VM's forwarded ports and `/etc/hosts` referenced a CIDR that
changed between boots), and **service-to-service traffic had no one place it could be
observed or restricted**.

## Decision

Every compose file attaches its services to one extended, external named bridge,
`traefik_services`, whose properties are configurable variables (`SIMVA_SERVICE_NETWORK`,
`SIMVA_NETWORK_INTERFACE`, `SIMVA_NETWORK_CIDR`) and whose creation is the job of the
`00-network` stack — a `noop` service that exists only so network creation has a stack
number and a deterministic place in the boot order. Inside the bridge, services address each
other by `<subdomain>.${SIMVA_INTERNAL_DOMAIN}` hostnames, so DNS is identity and no port
is published for a service's private peers.

The deciding commit is explicit about the intent: "Specifying and make configurable the
shared network bridge **name and network address**."

## Consequences

**Positive**

- The host always knows the address space: `SIMVA_NETWORK_CIDR=172.30.0.0/24` on interface
  `simva0` is predictable, so firewall rules and VM port forwards are stable configuration,
  not archaeology.
- Service discovery is uniform (a hostname per subdomain), and inter-stack traffic has a
  single named bridge where a future policy could be attached.
- Booting is deterministic: `00-network` must come up first or no one else can join the
  bridge — the wait hooks catch it.

**Negative**

- **One bridge means flat trust.** Every service can reach every other service's port; the
  coarse network is the boundary. Kafka still gets its own `kafka_services` bridge
  (`SIMVA_KAFKA_NETWORK`), which is the acknowledgement that the "one network" rule has one
  carve-out.
- **The CIDR is fixed per instance.** Two SIMVA environments on one host cannot both own
  `172.30.0.0/24`; the family of variables makes it *configurable*, not *multi-tenant*.

## Evidence

- `a96b1bd` (2020-06-24) — shared, configurable bridge name and address
- `00-network/docker-compose.yml` — the canonical definition (bridge `traefik_services`,
  interface `simva0`, subnet `172.30.0.0/24`)
- The `network: traefik_services: external: true` stanza present in every stack's compose

## Related

- [Networking and TLS](../networking-and-tls.md)
- [ADR-0005](0005-traefik-fronts-everything.md) — the one entrypoint on top of this bridge
- [ADR-0001](0001-numbered-stacks-one-script.md) — why `00-network` exists at all