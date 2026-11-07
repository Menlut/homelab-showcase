# Frontend — Jellyfin & Seerr

Media streaming and requests, independent of the acquisition VPN namespace.

[Compose configuration](docker-compose.yml) · [Shared environment file](../.env.example) · [Media deployment instructions](../README.md)

## What to know

- Web: `jellyfin.example.com` and `seerr.example.com`.
- These Caddy routes use **private access**, not Authentik forward auth, to support TV and native clients.
- Persistent settings: `./jellyfinconfig`, `./jellyfincache`, `./seerrconfig`; Jellyfin reads `${MEDIA_PATH}`.

## Shared environment variables

Only variables relevant to this component are listed here. The [parent media README](../README.md) lists **every** variable in the shared `.env`.

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `MEDIA_PATH` | Host folder containing shared media libraries/downloads. |
| `JELLYFIN_WEB_PORT` | Host port for the Jellyfin web interface. |
| `SEERR_WEB_PORT` | Host port for the Seerr web interface. |

## Setup notes

- Configure users and authentication **inside Jellyfin and Seerr**.
- Review media-library permissions and parent `.env` port settings.

**Deploy through [`../compose.yml`](../compose.yml), not this subfolder.**
