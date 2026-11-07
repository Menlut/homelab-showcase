# Speedtest Tracker

ISP speed-test history and dashboard.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Web: `beelink-speedtest.example.com` → `127.0.0.1:61211`; Authentik forward auth.
- Persist `./beelink-speedtest-tracker-config` with the original encryption key.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `APP_KEY` | Persistent Speedtest Tracker encryption key (`base64:` format). |
| `TZ` | Timezone for application timestamps and schedules. |
| `URL` | Public Speedtest Tracker URL. |

## Setup and credentials

For a **new** Speedtest Tracker installation, generate `APP_KEY` with its required `base64:` prefix:

```bash
echo "base64:$(openssl rand -base64 32)"
```

Keep the **same key** if restoring the database; replacing it can make encrypted data unreadable.

## Deploy / check

```bash
cd /home/homelab/docker/monitoring-services/beelink-speedtest-tracker
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
