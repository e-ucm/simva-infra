# Manage the instance env files and secrets

`etc/simva.d/simva-env.sh` and `etc/simva.d/simva-env.dev.sh` hold credentials, so they are
**not committed**. Only the templates `simva-env.example.sh` and `simva-env.dev.example.sh`
are tracked. Secrets in the templates use the placeholder `CHANGEME1234`.

## First run

`./simva` creates any missing real file from its template (`bin/sync-env-template.sh`).

| Mode | Behaviour |
| --- | --- |
| Local development (`SIMVA_ENVIRONMENT="development"` and `SIMVA_DEVELOPMENT_LOCAL="true"`) | Default `CHANGEME1234` secrets are allowed. |
| Anything else (production, or development with `SIMVA_DEVELOPMENT_LOCAL` not `true`) | `./simva` aborts and lists every variable still set to `CHANGEME1234`. Edit the file and run again. |

## Keeping files in sync

On every `./simva` run (changed env files are backed up to `backup/simva-env/` first):

- Variables in the template but missing from your real file are **appended** to it.
  Your existing values are never overwritten.
- Variables in your real file but missing from the template are **added to the template**.
  Names with a `PASS*`, `SECRET`, `TOKEN` or `KEY` word (e.g. `*_PASSWORD`, `*_API_KEY`, not
  `KEYCLOAK`) get the value `CHANGEME1234`; other
  values are copied as-is, so do not keep sensitive data in other names.
  The template change is local; review and commit it yourself.

## Preventing accidental commits

- `etc/simva.d/.gitignore` ignores the real files and `backup/`.
- `.githooks/pre-commit` rejects staged `etc/simva.d/simva-env*.sh` files that are not
  `*.example.sh`. It also rewrites every secret-named variable in a staged `*.example.sh`
  to `CHANGEME1234` and re-stages the file (it refuses if the file has unstaged edits). Add a
  trailing `# nosecret` comment to a variable that is not a secret, e.g. a key file name.
  Enable it once per clone:

  ```bash
  git config core.hooksPath .githooks
  ```

## CI

`.github/workflows/simva-smoke.yml` copies the templates and runs three jobs:

- `production` and `development`: every `CHANGEME1234` is replaced with a random password
  (`SIMVA_DEVELOPMENT_LOCAL` is set to `false` for `development`).
- `development-local`: `SIMVA_DEVELOPMENT_LOCAL="true"` and the default secrets are kept, to
  prove local development works with them. The sources local mode expects next to
  `simva-infra` (`${SIMVA_HOME}/../..`) are cloned by the `before-start` hooks (see below); the
  job only sets the four `SIMVA_*_LOCAL_DEPLOYMENT` flags to `true`.

## Secrets committed in the past

Earlier commits contain real passwords. Rotate them; removing them from history needs
`git filter-repo` and a force-push.

## Local deployment checkout hooks

When a `SIMVA_*_LOCAL_DEPLOYMENT` flag is `true`, a `before-start` hook clones the sources into
the matching `*_LOCAL_PATH` if the folder is missing or empty. An existing folder is never
touched, so your own work is kept.

| Flag | Stack hook | Repo @ ref |
| --- | --- | --- |
| `SIMVA_KEYCLOAK_EXTENSION_LOCAL_DEPLOYMENT` | `03-keycloak/.../02-checkout-keycloak-extensions-code.sh` | `keycloak-extensions@v$SIMVA_KEYCLOAK_EXTENSIONS_VERSION` |
| `SIMVA_KAFKA_EXTENSION_LOCAL_DEPLOYMENT` | `06-kafka/.../09-checkout-kafka-extensions-code.sh` | `kafka-extensions@v$SIMVA_KAFKA_EXTENSIONS_VERSION` |
| `SIMVA_LIMESURVEY_PLUGIN_LOCAL_DEPLOYMENT` | `04-limesurvey/.../15-checkout-limesurvey-plugins-code.sh` | the three plugins @ `v$SIMVA_LIMESURVEY_*_PLUGIN_VERSION` |
| `SIMVA_DEVELOPMENT_LOCAL` (stack code) | `20-simva/.../10-checkout-code.sh` | `simva`, `simva-front`, `simva-trace-allocator` @ `v$SIMVA_SIMVA_VERSION`, `v$SIMVA_SIMVA_FRONT_VERSION`, `v$SIMVA_SIMVA_TRACE_ALLOCATOR_VERSION` |
| `SIMVA_DEVELOPMENT_LOCAL` (stack code) | `21-tmon/.../20-checkout-code-tmon.sh` | `t-mon@v$SIMVA_TMON_VERSION` |
| `SIMVA_DEVELOPMENT_LOCAL` (stack code) | `04-limesurvey/.../00-get-limesurvey-docker-git.sh` | `docker-limesurvey@$SIMVA_LIMESURVEY_DOCKER_GIT_REF` (default `$SIMVA_LIMESURVEY_VERSION`) |
| `SIMVA_XASUJS_LIBRARY_LOCAL_DEPLOYMENT` | `20-simva/.../05-checkout-xasujs-code.sh` | `xasu-js@$SIMVA_XASUJS_GIT_REF` |

They share `checkout_local_repo` from `bin/extension-helper.sh`.
