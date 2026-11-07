# Uptime Kuma — Availability

Health/availability checks and notifications.

[Compose configuration](docker-compose.yml)

## Before starting

- Web: `uptime-kuma.example.com` → `127.0.0.1:3001`; Authentik forward auth.
- Persistent monitors, user accounts and notifications: `./uptime-kuma-data`.
- Read-only Docker socket is mounted for container monitoring.

## Environment variables

No `.env` file is supplied for this stack; app settings are managed in the application UI or its mounted configuration.

## Setup and credentials

This stack uses no `.env`. Configure monitors, notifications and UI accounts inside Uptime Kuma. The Docker socket mount permits container monitoring, so restrict who can administer this service.

## Deploy / check

```bash
cd /home/homelab/docker/monitoring-services/uptime-kuma
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
