# Portainer — Docker UI

Privileged container-management interface.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Web: `portainer.example.com` (Caddy routes to local port `9000`); local HTTPS port `9443` is also bound.
- Docker socket access allows host administration. Keep access tightly restricted.
- Persist settings at `./portanier-data` (**original folder spelling**).

## Authentik SSO

[Authentik integration guide — Portainer](https://integrations.goauthentik.io/hypervisors-orchestrators/portainer/). Configure OAuth in Portainer’s own Authentication settings as well as in Authentik.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |

## Setup and credentials

`TZ` is the only `.env` key. Initial user accounts, SSO and roles are configured in **Portainer / Authentik**, not by a password variable here. Docker socket access gives this service elevated control.

## Deploy / check

```bash
cd /home/homelab/docker/infrastructure-services/portainer
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
