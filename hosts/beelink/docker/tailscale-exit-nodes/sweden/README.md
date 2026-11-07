# Sweden — Tailscale VPN Exit Node

Independent Tailscale exit node routed through Proton VPN (Gluetun) for Sweden; not the Beelink’s host Tailscale service.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Gluetun + web UI + Tailscale + `tailscale-route-fix.sh` operate together; keep routing and NET_ADMIN/TUN configuration unchanged.
- Web: `sweden-gluetun-web-ui.example.com` → local `${GLUETUN_WEBUI_PORT}`; Authentik forward auth.
- Preserve `./sweden-gluetundata` and `./sweden-tailscaledata` (Tailscale identity).

## Environment variables

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |
| `WIREGUARD_KEY` | Private key from the Sweden Proton VPN WireGuard profile. |
| `TAILSCALE_AUTHKEY` | Device registration key issued by Tailscale Admin. |
| `TAILSCALE_HOSTNAME` | Tailscale node name advertised to the tailnet. |
| `TAILSCALE_PORT` | UDP port used by the containerized Tailscale node. |
| `VPN_COUNTRY` | Target country checked by exit-node routing script. |
| `VPN_SERVER_HOSTNAMES` | Allowed Proton VPN server hostnames for this exit node. |
| `GLUETUN_WEBUI_PORT` | Local port for the Sweden Gluetun web interface. |

## Setup and credentials

Get the **Sweden Proton VPN WireGuard private key** from the VPN profile and a `TAILSCALE_AUTHKEY` from **Tailscale Admin**. Neither is a random OpenSSL password. Keep the node's persistent Tailscale identity; review the expected country and hostname and approve exit-node use in Tailscale Admin.

## Deploy / check

```bash
cd /home/homelab/docker/tailscale-exit-nodes/sweden
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
