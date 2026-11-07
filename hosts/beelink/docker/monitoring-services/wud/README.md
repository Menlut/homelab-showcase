# WUD — Image Update Monitoring

Watches Docker image updates; current update policy is **manual**, not unattended.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Web: `wud.example.com` → `127.0.0.1:61212`; native Authentik SSO.
- Has Docker socket access and reads the live Docker tree through `${DOCKER_ROOT}:/stacks`. This is a high-trust tool.
- Persist WUD state at `./store`.

## Authentik SSO

[Authentik integration guide — What's Up Docker (WUD)](https://integrations.goauthentik.io/monitoring/whats-up-docker/). Follow the WUD OIDC application/provider and redirect settings.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |
| `WUD_OIDC_CLIENT_ID` | WUD OIDC client ID from Authentik. |
| `WUD_OIDC_CLIENT_SECRET` | WUD OIDC client secret from Authentik. |
| `WUD_AUTH_OIDC_AUTHENTIK_DISCOVERY` | Authentik discovery endpoint used by WUD. |
| `DOCKER_ROOT` | Path to live Docker files mounted read-only/for WUD visibility. |
| `WUD_TELEGRAM_BOT_TOKEN` | Telegram bot API token for update notifications. |
| `WUD_TELEGRAM_CHAT_ID` | Telegram destination chat ID for notifications. |
| `WUD_REGISTRY_GHCR_HOMELAB_TOKEN` | GitHub credential for WUD to check GHCR images. |
| `GHCR_USER` | GitHub username used for GHCR queries. |

## Setup and credentials

Register WUD's OIDC client in **Authentik Admin**. Get Telegram credentials from Telegram and GHCR credentials from GitHub; OpenSSL cannot create valid service tokens. `DOCKER_ROOT` must point to **live** `/home/homelab/docker`, not this checkout. Updates require manual review.

## Deploy / check

```bash
cd /home/homelab/docker/monitoring-services/wud
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
