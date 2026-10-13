# 2. Development mode

Tutorial 1 left you with a **development** environment already — `SIMVA_ENVIRONMENT` defaults
to `development`. What that buys you is access to the tool UIs that have no place in
production: a `whoami` smoke-test service, a CSP violation reporter, database browsers,
Kafka UI, a Jupyter notebook, the Dozzle log viewer and Portainer.

This lesson switches the extra services on, so that when a stack is misbehaving you can look
inside it from a browser.

## Step 1 — Read which services stay development-only

Programmers have split every stack's compose file into variants (see
[reference/stacks.md](../reference/stacks.md)). In a stack folder such as `01-traefik`, the
file `etc/simva.d/simva-env.sh` then merges them:

```bash
export COMPOSE_FILE="docker-compose.yml"
if [[ "${SIMVA_ENVIRONMENT}" == "production" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"
else
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
    ...
fi
```

Rules that only exist in development files — `whoami`, `csp-reporter`, `phpmyadmin`,
`kafka-ui`, `zoonavigator`, `simva-mongo-ui`, `simva-sqlite-ui`, `shlink-admin`, `jupyter`,
`portainer`, `dockhand` — therefore exist only when `SIMVA_ENVIRONMENT=development`.

## Step 2 — Make sure the URLs resolve

The new UIs are published on subdomains of the external domain, so repeat the hosts step from
[tutorial 1](./01-first-launch.md) for the ones you want (same `172.30.0.1` target), e.g.:

```text
172.30.0.1  kafka-ui.external.test
172.30.0.1  zoonavigator.external.test
172.30.0.1  phpmyadmin.external.test
172.30.0.1  simva-mongo-ui.external.test
172.30.0.1  jupyter.external.test
172.30.0.1  logs.external.test
172.30.0.1  portainer.external.test
```

## Step 3 — (optional) Local repositories instead of checked-out copies

In development, the `simva`, `simva-front`, `tmon`, `pumva` and `limesurvey` images are
checked out and built from their own git references (`SIMVA_*_GIT_REF`, set in
`etc/simva.d/simva-env.dev.sh`). If your sibling repositories live next to this one, you can
run against them instead:

```bash
export SIMVA_DEVELOPMENT_LOCAL="true"
```

Read in `etc/simva.install.d/simva-env.dev.sh`: it points the builds and volume mounts at
`../../simva`, `../../simva-front`, `../../js-tracker`, `../../keycloak-extensions` and so
on, instead of cloning into `data/`. Leave it `false` when you only want stock images.

## Step 4 — Look inside a service

The logging stack speaks again. In a terminal:

```bash
./simva log 07-simva
docker ps --filter name=simva
```

And in your browser:

- `https://logs.external.test/` — **Dozzle**, live logs of every container,
- `https://portainer.external.test/` — **Portainer** (admin password from
  `SIMVA_PORTAINER_ADMIN_PASSWORD`, default `password1234`),
- `https://kafka-ui.external.test/` — browse topics and the sink's offset,
- `https://simva-mongo-ui.external.test/` — the SIMVA database.

You now know the difference between the two big dials: `SIMVA_ENVIRONMENT` decides *which
compose file set* a stack runs, and `SIMVA_DEVELOPMENT_LOCAL` decides *whose code* is
mounted into it. When something breaks, that is the first thing to check.