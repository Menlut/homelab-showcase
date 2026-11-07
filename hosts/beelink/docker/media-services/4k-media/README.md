# 4K Media — Radarr, Sonarr, Bazarr

Separate media managers for 4K releases.

[Compose configuration](docker-compose.yml) · [Shared environment file](../.env.example) · [Media deployment instructions](../README.md)

## What to know

- All three share `media-gluetun` networking and the parent project.
- Web: `radarr-4k.example.com`, `sonarr-4k.example.com`, `bazarr-4k.example.com` (Authentik forward auth).
- Settings: `./4k-radarrconfig`, `./4k-sonarrconfig`, `./4k-bazarrconfig`.

## Shared environment variables

Only variables relevant to this component are listed here. The [parent media README](../README.md) lists **every** variable in the shared `.env`.

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `MEDIA_PATH` | Host folder containing shared media libraries/downloads. |
| `RADARR_4K_WEB_PORT` | Host loopback port for 4K Radarr; separate from optimized. |
| `SONARR_4K_WEB_PORT` | Host loopback port for 4K Sonarr; separate from optimized. |
| `BAZARR_4K_WEB_PORT` | Host loopback port for 4K Bazarr; separate from optimized. |

## Setup notes

- Uses shared `MEDIA_PATH` plus **distinct 4K ports** from [parent `.env`](../.env.example).
- Keep 4K profiles and paths separate from optimized instances.

**Deploy through [`../compose.yml`](../compose.yml), not this subfolder.**
