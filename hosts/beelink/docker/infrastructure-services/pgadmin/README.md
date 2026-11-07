# pgAdmin — PostgreSQL GUI

Browser interface for managing databases attached to the shared admin network.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Web: `pgadmin.example.com` → `127.0.0.1:5050`.
- External network: `database-admin-network`.
- The shared network(s) must exist on the Docker host before deployment.
- Persist pgAdmin settings in `./pgadmin-data`.

## Authentik SSO

[Authentik integration guide — pgAdmin](https://integrations.goauthentik.io/infrastructure/pgadmin/). Follow the provider/redirect setup and configure pgAdmin’s OAuth settings.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `PGADMIN_DEFAULT_EMAIL` | Potential initial pgAdmin login email; not used by supplied Compose. |
| `PGADMIN_DEFAULT_PASSWORD` | Potential initial login password; not used by supplied Compose. |
| `OAUTH2_SERVER_METADATA_URL` | Authentik OIDC discovery endpoint used by pgAdmin. |
| `PGADMIN_OIDC_CLIENT_ID` | pgAdmin OIDC client ID issued in Authentik. |
| `PGADMIN_OIDC_CLIENT_SECRET` | pgAdmin OIDC client secret issued in Authentik. |

## Setup and credentials

Create the OIDC client in **Authentik Admin** and copy the issued values. The supplied Compose does **not** interpolate `PGADMIN_DEFAULT_EMAIL` or `PGADMIN_DEFAULT_PASSWORD`; changing those two `.env` values alone will not configure a login. Account management and OAuth2 setup also involve pgAdmin itself.

## Deploy / check

```bash
cd /home/homelab/docker/infrastructure-services/pgadmin
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
