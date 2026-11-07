# Media Services — Example Stack (Not Auto-Started)

Five components share **one** parent Compose project. The folder name `aquisition/` is intentional. **Do not start component folders separately:** several services share Gluetun's network namespace.

[Compose configuration](compose.yml) · [Shared environment file](.env.example)

## Components

- [Acquisition](aquisition/README.md): Gluetun VPN, qBittorrent, port syncing and Prowlarr.
- [Optimized](optimized-media/README.md): Radarr, Sonarr and Bazarr for optimized media.
- [4K](4k-media/README.md): separate Radarr, Sonarr and Bazarr instances.
- [Processing](processing/README.md): FileFlows media processing.
- [Frontend](frontend/README.md): Jellyfin and Seerr, each with its own login.

Create a local environment file before use:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git.

## Before enabling

Check the media mount and Intel GPU group IDs before enabling services:

```bash
getent group video
getent group render
```

Get `WIREGUARD_KEY` from a **Proton VPN WireGuard profile**, not OpenSSL. `QBT_USER` and `QBT_PASS` must match qBittorrent's Web UI login for PortSync. Configure the Caddy routes and Authentik access. The VPN-dependent managers share Gluetun's network namespace and must start with a healthy VPN.

## Shared environment variables

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `VIDEO_GID` | Host video group ID for hardware acceleration. |
| `RENDER_GID` | Host render group ID for hardware acceleration. |
| `MEDIA_PATH` | Host folder containing shared media libraries/downloads. |
| `WIREGUARD_KEY` | Private key from the selected Proton VPN WireGuard profile. |
| `VPN_SERVER_COUNTRIES` | Allowed Proton VPN exit countries for the media VPN. |
| `QBT_USER` | qBittorrent Web UI username for PortSync authentication. |
| `QBT_PASS` | qBittorrent Web UI password for PortSync authentication. |
| `GLUETUN_WEBUI_PORT` | Host loopback port for the Gluetun web UI. |
| `QBT_WEB_PORT` | Host loopback port for qBittorrent. |
| `PROWLARR_WEB_PORT` | Host loopback port for Prowlarr. |
| `RADARR_OPT_WEB_PORT` | Host loopback port for optimized Radarr. |
| `SONARR_OPT_WEB_PORT` | Host loopback port for optimized Sonarr. |
| `BAZARR_OPT_WEB_PORT` | Host loopback port for optimized Bazarr. |
| `RADARR_4K_WEB_PORT` | Host loopback port for 4K Radarr; separate from optimized. |
| `SONARR_4K_WEB_PORT` | Host loopback port for 4K Sonarr; separate from optimized. |
| `BAZARR_4K_WEB_PORT` | Host loopback port for 4K Bazarr; separate from optimized. |
| `FILEFLOWS_WEB_PORT` | Host loopback port for FileFlows. |
| `JELLYFIN_WEB_PORT` | Host port for the Jellyfin web interface. |
| `SEERR_WEB_PORT` | Host port for the Seerr web interface. |

## Deploy together

```bash
cd /home/homelab/docker/media-services
docker compose -f compose.yml config --quiet
docker compose -f compose.yml up -d --pull never
docker compose -f compose.yml ps
```

Use this command **only when intentionally activating** the media stack. See each component for its special requirements.

### Stop all media services except Jellyfin

Jellyfin already has `profiles: [jelly]` in `frontend/docker-compose.yml`. This does **not** require editing the Compose file. Run from the parent media folder:

```bash
cd /home/homelab/docker/media-services

# Start/keep only Jellyfin; --no-deps prevents starting other services.
docker compose -f compose.yml --profile jelly up -d --no-deps --pull never jellyfin

# Stop the other services without deleting their data or stopping Jellyfin.
docker compose -f compose.yml --profile jelly config --services \
  | grep -vx 'jellyfin' \
  | xargs -r docker compose -f compose.yml stop

# Verify what is still running.
docker compose -f compose.yml --profile jelly ps
```

Use `stop`, not `down`: Jellyfin is part of the same Compose project, and `down` would also stop it. To start all media services **including** Jellyfin later:

```bash
cd /home/homelab/docker/media-services
docker compose -f compose.yml --profile jelly up -d --pull never
```
