# 1. Your first SIMVA environment

This lesson gets a complete SIMVA running on your machine, once, without explaining the
machinery. When you finish, you will have:

- `https://external.test/` — the SIMVA front end,
- `https://sso.external.test/` — the Keycloak SSO,
- `https://limesurvey.external.test/`, `https://minio.external.test/`,
  `https://tmon.external.test/` and the rest — one service per subdomain.

The commands assume you have followed the preparation in the
[tutorials README](./README.md).

## Step 1 — Get the sources

Clone the project and choose the branch you want to deploy. Branches are deployed
snapshots (`rustfs`, `development`, `master`, …): normal deployments pick exactly one
branch and stay on it.

```bash
git clone https://github.com/e-ucm/simva-infra.git
cd simva-infra
git checkout rustfs          # or the branch for your environment
```

> Linux natively? Skip straight to the next section. Windows or macOS? Use the Vagrant VM
> instead: `cd vagrant && ./2-run-vagrant-image.sh --memory 8 --cpu 4` — then `ssh vagrant`
> into the VM and work there. Vagrant boots a Linux VM with Docker and all dependencies
> pre-installed and forwards the guest's ports 80/443 to host ports `2800X`/`2900X` (X = the
> last octet of the VM's IP; default `28001`/`29001`, overridable with `VBOX_HOST_HTTP_PORT`
> / `VBOX_HOST_HTTPS_PORT`).

## Step 2 — Look at the configuration

SIMVA reads its configuration from the environment, tracked as executable shell files that
source each other:

```bash
cd docker-stacks
sudo su                       # the simva script requires root
./simva help                  # lists the operations
```

The first `./simva` run creates `etc/simva.d/simva-env.sh` from `simva-env.example.sh` (the
real file is untracked). Open it and read a few of the variables: `SIMVA_ENVIRONMENT`,
`SIMVA_EXTERNAL_DOMAIN`, `SIMVA_INTERNAL_DOMAIN`, and the `SIMVA_*_PASSWORD` block at the
bottom. Those are *your* instance's answers to "which domain", "which services" and
"which passwords".

Outside local development (`SIMVA_DEVELOPMENT_LOCAL="true"`), every `CHANGEME1234` password
must also be replaced before `./simva` will start; see
[manage-env-secrets](../how-to/manage-env-secrets.md).

One of them you must change before the first run. SIMVA's TLS default is
`SIMVA_TLS_GENERATE_SELF_SIGNED="false"`, which means "I will provide a real wildcard
certificate for my domain" — and a freshly launched environment refuses to start without it.
This experiment has no certificate yet, so switch it to self-signed:

```bash
export SIMVA_TLS_GENERATE_SELF_SIGNED="true"
```

Now SIMVA will generate its own root CA with `mkcert` (under `config/tls/ca/`) and sign a
wildcard certificate for `external.test` from it. The rest of the defaults are safe for a
local experiment:

```bash
SIMVA_ENVIRONMENT="development"
SIMVA_EXTERNAL_DOMAIN="external.test"
SIMVA_INTERNAL_DOMAIN="internal.test"
```

Because every service is published as `<subdomain>.<external-domain>`, you need those host
names to resolve to your machine before browsers can reach them. The environment ships
without DNS on purpose; add a line to your machine's `/etc/hosts` when testing:

```text
172.30.0.1  external.test
172.30.0.1  *.external.test
```

`172.30.0.1` is the Vagrant VM's static private-network IP (and, on the shared bridge,
the host's own address). If you deploy natively and gave the bridge a different subnet,
use your machine's address instead. The wildcard entry is needed because the pages live on
distinct subdomains; if your editor or OS rejects wildcards, add each subdomain you actually
visit — `external.test`, `sso.external.test`, `limesurvey.external.test`,
`minio.external.test`, `tmon.external.test`.

## Step 3 — Start the environment

One command launches everything, in order: network, Traefik, logs, Keycloak, LimeSurvey,
MinIO, Kafka, Shlink, LRS, SIMVA, TMon, PUMVA.

```bash
./simva start
```

On the first run this is slow: images are pulled, the wildcard TLS certificate is generated,
the Keycloak `simva` realm is created, the LimeSurvey SAML setup is prepared, the MinIO
policies and event buckets are installed, the Kafka sink is configured, and the databases
are initialized. The script doubles its own wait times on a fresh start and tells you so:

```text
SIMVA it is not initialized, this launch will take longer than normal.
```

Watch it. If a dependency is not ready in time, the stack's `after-start.d` hook retries a
bounded number of times (`SIMVA_MAX_RETRIES`); the run only finishes when every stack has
run its health checks.

## Step 4 — Verify it is alive

When the command returns, check that the containers are up:

```bash
./simva log 01-traefik
docker ps
```

Then open the front page, trusting the self-signed CA that SIMVA created for you:

```bash
curl -k https://external.test/
```

Why `-k`? SIMVA generated its own root CA and a wildcard certificate for your domain
(`SIMVA_TLS_GENERATE_SELF_SIGNED="true"`). Browsers do not trust it until you install the
root CA on the machine you are browsing from; for a first look, telling curl to skip
verification is enough. (When you deploy for real, flip TLS back to `false` and provide your
certificate — see [update TLS certificates](../how-to/update-tls-certificates.md).)

## Step 5 — Log in

The template **users** are created by the Keycloak hooks: `student`, `teaching-assistant`,
`teacher`, `researcher`, `administrator` and a few machine accounts
(`lrsmanager`, `garbagecollector`). Their passwords are generated at first login-setup if
you did not pin them in `etc/simva.d/simva-env.sh` — the hooks write the decided values into
`config/keycloak/simva-env.sh` (and `config/keycloak/realm-data.users.yml`). Read them
there:

```bash
grep "SIMVA_TEACHER_PASSWORD\|SIMVA_STUDENT_PASSWORD" config/keycloak/simva-env.sh
```

The sample users are listed in `docker-stacks/02-keycloak/README.md`, which documents them
with username-equals-password (`teacher`/`teacher`, `student`/`student`, …) — that is what
you get when you uncomment the `SIMVA_*_PASSWORD` lines. The Keycloak master-realm admin is
`admin`/`password` (`SIMVA_KEYCLOAK_ADMIN_USER`/`PASSWORD`), and the console lives at
`https://sso.external.test/admin`.

Open `https://external.test/` and sign in with a user from `config/keycloak/simva-env.sh`.
You are in: the API, the front end, the survey service, the storage and the dashboard are all
talking to each other over the internal network.

## Things you now know without having read the code

- One script, `./simva`, owns the whole lifecycle and demands root.
- Configuration is environment variables, not files you edit deep inside containers.
- Containers create all their own certificates, realms, buckets and policies on first start.
- Stop and start are symmetric and graceful:

```bash
./simva stop        # graceful, no data loss, named volumes survive
./simva start       # states are remembered via data/<stack>/.initialized markers
```

The next lesson turns the development dial, so you can see the internal tools. When you are
ready to understand *why* it is layered like this, read the
[explanation section](../explanation/README.md).