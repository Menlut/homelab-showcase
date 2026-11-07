# Caddy — HTTPS & Routing

Host-network reverse proxy example. The original setup used a **privately built custom Caddy image** with the Cloudflare DNS plugin. That image and its build process are **not included** in this public repository. The Compose image `ghcr.io/example-user/caddy-cloudflare:2.11.9-cf0.2.4-r1` is a placeholder, not a downloadable image.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Choosing a Caddy image

Use your own build or a Caddy image from a source you trust; update `image:` in [Compose configuration](docker-compose.yml) before deploying. The [official Caddy project](https://github.com/caddyserver/caddy) and [official Caddy Docker image repository](https://github.com/caddyserver/caddy-docker) are good starting points.

**Important:** The standard `caddy` image does not include the [Cloudflare DNS module](https://github.com/caddy-dns/cloudflare). This example Caddyfile uses `acme_dns cloudflare`, so a compatible build containing that module is required. Otherwise, change the TLS/ACME configuration to a supported method. See the official sources before changing the image.

For my private homelab, I built my own custom Caddy image with the Cloudflare DNS module instead of using the standard image.

## Before starting

- Runs on the host network, including ports 80 and 443.
- [Caddyfile](Caddyfile) shows **representative routes only** (native SSO, forward auth and own-login apps). Add your own routes and configure Authentik's providers before deploying. Replace `example.com`, LAN/Docker ranges, and example upstream ports as needed.
- Keep `./caddy-data` (certificates) and `./caddy-config`.


## Tailscale IP allowlist

The `100.64.0.0/10` range in the [Caddyfile](Caddyfile) covers the shared IPv4 space used by Tailscale devices **across all tailnets**; it is **not unique to this homelab** and is also used for carrier-grade NAT. A Caddy `remote_ip 100.64.0.0/10` matcher checks only the connection’s source IP. It does **not** authenticate a device or prove membership in your tailnet. Tailnet isolation depends on Tailscale connectivity and access policies. Keep Caddy accessible only through intended network paths, and retain Authentik or application authentication where appropriate. `100.101.102.103` is one example device address, not a client allowlist.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `CLOUDFLARE_API_TOKEN` | Cloudflare-issued API token for ACME DNS challenge. |

## Setup and credentials

Create a scoped DNS-edit API token in **Cloudflare** and place it in a local `.env`; a random OpenSSL string is **not** a valid Cloudflare token. Review the [Caddyfile](Caddyfile) for routes and auth behavior.

## Deploy / check

```bash
cd /home/homelab/docker/infrastructure-services/caddy
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```

## Historical Caddy Dockerfile

I originally extended the standard Caddy image with a small Dockerfile. I later moved **custom-image builds and update maintenance to a separate private repository**, rather than maintaining the build alongside my application deployment configurations. This makes version tracking and rebuilding the image easier to maintain.

A Dockerfile can add capabilities missing from an upstream image. My earlier example used **`xcaddy` at build time** to include the Cloudflare DNS plugin. The original file is preserved here as [plain text](Dockerfile.legacy.txt) for reference; it is **historical, not the build used by this public Compose example**:

```dockerfile
FROM caddy:2-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

The build above is illustrative and unpinned. For an actively maintained deployment, select supported image versions, review upstream releases and use a compatible build with the required plugin. The [official Caddy Docker repository](https://github.com/caddyserver/caddy-docker) documents the current approach to custom builds.
