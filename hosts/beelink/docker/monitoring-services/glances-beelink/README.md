# Glances — System Metrics

Beelink host and container metrics.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Web: `glances-beelink.example.com` → `127.0.0.1:61209`; Authentik forward auth.
- Read-only Docker socket plus host filesystem and `/srv/storage` mounts provide sensitive system information.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |

## Setup and credentials

`TZ` is the only variable. Restrict the dashboard with the existing **Authentik forward-auth** policy; the host/Docker mounts expose detailed system data.

## Deploy / check

```bash
cd /home/homelab/docker/monitoring-services/glances-beelink
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
