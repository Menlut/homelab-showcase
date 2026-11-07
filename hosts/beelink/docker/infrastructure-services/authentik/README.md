# Authentik — Identity

Central identity service with server, worker and PostgreSQL.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Web: `auth.example.com` → `127.0.0.1:9099`.
- External network: `database-admin-network` for its Postgres database.
- The shared network(s) must exist on the Docker host before deployment.
- Keep `./authentik-postgres-data`, `./authentik-data`, `./authentik-templates` and `./authentik-certs`.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |
| `AUTHENTIK_SECRET_KEY` | Persistent Authentik application signing/encryption secret. |
| `AUTHENTIK_DB_NAME` | Authentik PostgreSQL database name. |
| `AUTHENTIK_DB_USER` | Authentik PostgreSQL account. |
| `AUTHENTIK_DB_PASSWORD` | Authentik PostgreSQL password; preserve on restore. |

## Setup and credentials

For a **new installation only**, generate two independent values:

```bash
# PostgreSQL password
openssl rand -base64 36

# Authentik secret key
openssl rand -base64 60
```

**Keep the original values** when restoring Authentik. Configure providers, outposts and group policies in **Authentik Admin**.

## Deploy / check

```bash
cd /home/homelab/docker/infrastructure-services/authentik
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
