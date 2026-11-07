# Optimized Media — Radarr, Sonarr, Bazarr

Separate media managers for the optimized library.

[Compose configuration](docker-compose.yml) · [Shared environment file](../.env.example) · [Media deployment instructions](../README.md)

## What to know

- All three share `media-gluetun` networking and cannot run as an independent Compose project.
- Web: `radarr-optimized.example.com`, `sonarr-optimized.example.com`, `bazarr-optimized.example.com` (Authentik forward auth).
- Settings: `./optimized-radarrconfig`, `./optimized-sonarrconfig`, `./optimized-bazarrconfig`.

## Shared environment variables

Only variables relevant to this component are listed here. The [parent media README](../README.md) lists **every** variable in the shared `.env`.

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `MEDIA_PATH` | Host folder containing shared media libraries/downloads. |
| `RADARR_OPT_WEB_PORT` | Host loopback port for optimized Radarr. |
| `SONARR_OPT_WEB_PORT` | Host loopback port for optimized Sonarr. |
| `BAZARR_OPT_WEB_PORT` | Host loopback port for optimized Bazarr. |

## Setup notes

- Uses the shared `MEDIA_PATH` and ports in [parent `.env`](../.env.example).
- Configure application-to-qBittorrent/Prowlarr connections after the shared VPN stack is running.

**Deploy through [`../compose.yml`](../compose.yml), not this subfolder.**
