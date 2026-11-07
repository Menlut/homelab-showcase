# Acquisition — VPN & Downloading

Shared Proton VPN / Gluetun namespace, Gluetun web UI, qBittorrent, PortSync and Prowlarr.

[Compose configuration](docker-compose.yml) · [Shared environment file](../.env.example) · [Media deployment instructions](../README.md)

## What to know

- Provides the shared VPN network used by both Radarr/Sonarr/Bazarr sets.
- Web UIs: `media-gluetun-ui.example.com`, `media-qbit.example.com`, `prowlarr.example.com`; Authentik forward auth.
- qBittorrent and Prowlarr settings: `./media-qbittorrentconfig` and `./prowlarrconfig`; Gluetun state: `./media-gluetundata`.

## Shared environment variables

Only variables relevant to this component are listed here. The [parent media README](../README.md) lists **every** variable in the shared `.env`.

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `WIREGUARD_KEY` | Private key from the selected Proton VPN WireGuard profile. |
| `VPN_SERVER_COUNTRIES` | Allowed Proton VPN exit countries for the media VPN. |
| `QBT_USER` | qBittorrent Web UI username for PortSync authentication. |
| `QBT_PASS` | qBittorrent Web UI password for PortSync authentication. |
| `GLUETUN_WEBUI_PORT` | Host loopback port for the Gluetun web UI. |
| `QBT_WEB_PORT` | Host loopback port for qBittorrent. |
| `PROWLARR_WEB_PORT` | Host loopback port for Prowlarr. |
| `MEDIA_PATH` | Host folder containing shared media libraries/downloads. |

## Setup notes

- Get the shared `WIREGUARD_KEY` from Proton VPN; `QBT_USER` / `QBT_PASS` must match qBittorrent settings.
- Check VPN connectivity and country before treating acquisition as operational.

**Deploy through [`../compose.yml`](../compose.yml), not this subfolder.**
