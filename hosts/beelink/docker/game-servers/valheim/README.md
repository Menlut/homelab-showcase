# Valheim — Dedicated Server

Valheim dedicated server with Vikinger management panel and RCON updater.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Game traffic: `${VALHEIM_PORT_1}`, `${VALHEIM_PORT_2}`, `${VALHEIM_PORT_3}` over **UDP**.
- Panel: `valheim-panel.example.com` → local `${PANEL_PORT}`; Authentik forward auth.
- The panel has privileged Docker socket access. Restrict its Authentik access.
- The `overrides/` and `scripts/update-rcon.py` files are used by the running stack. **The binary `overrides/rcon/ValheimRcon.dll` is deliberately omitted** from this public example. The startup hook requires it; obtain a compatible DLL from the publisher before starting, or let the included updater populate `overrides/rcon/` first. Do not commit downloaded binaries.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `TZ` | Timezone for application timestamps and schedules. |
| `SERVER_NAME` | Valheim server name displayed to players. |
| `WORLD_NAME` | Valheim world name; must match intended world on restore. |
| `SERVER_PASS` | Password for joining the Valheim server. |
| `SERVER_PUBLIC` | Whether the server appears in public listings. |
| `SERVER_ARGS` | Additional Valheim startup arguments/modifiers. |
| `MAX_PLAYERS` | Maximum number of connected players. |
| `VALHEIM_PORT_1` | Primary host UDP game port. |
| `VALHEIM_PORT_2` | Second host UDP game port. |
| `VALHEIM_PORT_3` | Third host UDP game port. |
| `BEPINEX` | Enable BepInEx mod support. |
| `VALHEIM_PLUS` | Enable ValheimPlus (kept off in this setup). |
| `PUBLIC_TEST` | Select public-test game branch instead of stable. |
| `CROSSPLAY` | Enable cross-platform play support. |
| `BACKUPS` | Enable Valheim scheduled world backups. |
| `BACKUPS_CRON` | Cron schedule for world backups. |
| `BACKUPS_MAX_AGE` | Maximum backup age in days. |
| `BACKUPS_MAX_COUNT` | Maximum number of retained backups (`0`: no count limit). |
| `BACKUPS_IF_IDLE` | Back up even when the server is idle. |
| `BACKUPS_ZIP` | Compress world backups. |
| `UPDATE_CRON` | Cron schedule for game-server updates. |
| `UPDATE_IF_IDLE` | Only update when the server is idle. |
| `RESTART_CRON` | Cron schedule for server restarts. |
| `RESTART_IF_IDLE` | Only restart when the server is idle. |
| `PERMISSIONS_UMASK` | File-permission mask used by the server. |
| `HOST_PROJECT_DIR` | Absolute host project directory mounted into Vikinger. |
| `PANEL_PORT` | Loopback port for the Vikinger web panel. |
| `DOCKER_GID` | Host group ID that can access the Docker socket. |
| `PANEL_DEFAULT_LOCALE` | Default language of the management panel. |
| `PANEL_RCON_TIMEOUT` | Standard RCON request timeout (seconds). |
| `PANEL_RCON_TIMEOUT_SLOW` | Timeout for slower RCON operations (seconds). |
| `PANEL_RCON_IDLE_SLOW` | Delay for slower RCON operations (seconds). |

## Setup and credentials

Set the server/world names and a `SERVER_PASS` meeting the Valheim image's accepted format (**needs verification**); do not reuse a new world name when restoring an existing world. `HOST_PROJECT_DIR` must match your actual host project directory. Vikinger generates RCON credentials when the modded setup is enabled; do not add a manual RCON password unless you are intentionally overriding it. Keep existing worlds and mods.

## Deploy / check

```bash
cd /home/homelab/docker/game-servers/valheim
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
