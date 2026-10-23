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

On every `./simva` run (a timestamped backup goes to `etc/simva.d/backup/` first):

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
  prove local development works with them.

## Secrets committed in the past

Earlier commits contain real passwords. Rotate them; removing them from history needs
`git filter-repo` and a force-push.
