# Stirling PDF

PDF processing, including an existing native Authentik OIDC setup and disabled server-side document storage.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Web: `pdf.example.com` → `127.0.0.1:${STIRLING_PDF_PORT}`.
- Keep `./stirling-configs`, `./stirling-tessdata`, `./stirling-customFiles` and logs.
- Verify `./rar/rar-bin` exists before deployment; Compose expects it as a read-only mount.

## Authentik SSO

[Authentik integration guide — Stirling PDF](https://integrations.goauthentik.io/documentation/stirling-pdf/). Use the guide to configure its OIDC provider and login callback.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `TZ` | Timezone for application timestamps and schedules. |
| `STIRLING_PDF_PORT` | Host loopback port for Stirling PDF and Caddy. |
| `STIRLING_DEFAULT_LOCALE` | Default user-interface language. |
| `STIRLING_PDF_URL` | Public Stirling PDF URL. |
| `STIRLING_FILE_UPLOAD_LIMIT` | Maximum permitted file upload size. |
| `STIRLING_OIDC_ISSUER` | Authentik issuer URL for Stirling SSO. |
| `STIRLING_OIDC_CLIENT_ID` | Stirling OIDC client ID from Authentik. |
| `STIRLING_OIDC_CLIENT_SECRET` | Stirling OIDC client secret from Authentik. |

## Setup and credentials

Create the OIDC application/provider in **Authentik Admin**, then copy its client ID and secret to your local `.env`. Confirm the issuer URL and authorized groups there. The secret is issued by the provider, not generated with OpenSSL.

## Deploy / check

```bash
cd /home/homelab/docker/applications/stirling-pdf
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
