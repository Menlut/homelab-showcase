# Wardrowbe — Closet & AI

Personal wardrobe application with PostgreSQL, Redis, backend, worker, frontend and a one-time database migration.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Application architecture

```text
     Browser
        |
        v
    Frontend -------------------> Backend API
                                    |   |   \
                                    |   |    +----> Ollama (AI)
                                    |   v
                                    |  Redis <----> Worker ----> Ollama (AI)
                                    v
                                PostgreSQL
                                    ^
                                    |
                          One-shot migration job
```

The backend uses PostgreSQL for persistent data and Redis for background tasks. The worker handles queued jobs and AI requests; the migration job updates the database schema, then exits. OIDC login is configured through Authentik.

## Before starting

- External networks: `database-admin-network` and `ai-services-network` (for Ollama).
- The shared network(s) must exist on the Docker host before deployment.
- Web: `closet.example.com` → `127.0.0.1:3010`; native Authentik OIDC.
- Preserve `./postgres_data`, `./redis_data` and `./wardrobe_data`.

## Authentik SSO

[Authentik integration guide — Wardrowbe (custom application)](https://docs.goauthentik.io/add-secure-apps/providers/oauth2/create-oauth2-provider/). No Wardrowbe-specific Authentik guide exists; create a standard OIDC provider and use this application’s `OIDC_*` settings.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `POSTGRES_USER` | PostgreSQL user for Wardrowbe. |
| `POSTGRES_PASSWORD` | PostgreSQL password; preserve for an existing database. |
| `POSTGRES_DB` | PostgreSQL database name for Wardrowbe. |
| `DEBUG` | Enable or disable backend debug mode. |
| `SECRET_KEY` | Wardrowbe backend signing/security key; required format needs verification. |
| `CORS_ORIGINS` | Allowed browser/frontend origins for backend requests. |
| `NEXTAUTH_URL` | Public frontend URL used in sign-in flows. |
| `NEXTAUTH_SECRET` | Frontend authentication/session signing secret. |
| `OIDC_ISSUER_URL` | Authentik issuer URL for Wardrowbe login. |
| `OIDC_CLIENT_ID` | Wardrowbe OIDC client ID from Authentik. |
| `OIDC_CLIENT_SECRET` | Wardrowbe OIDC client secret from Authentik. |
| `AUTH_TRUST_HEADER` | Whether the auth layer trusts forwarded host headers. |
| `AI_BASE_URL` | OpenAI-compatible Ollama API endpoint. |
| `AI_API_KEY` | API-key field for AI client; local Ollama uses `not-needed`. |
| `AI_VISION_MODEL` | Model used for image/vision analysis. |
| `AI_TEXT_MODEL` | Model used for text generation. |
| `AI_TIMEOUT` | AI request timeout (seconds). |
| `AI_MAX_RETRIES` | Maximum AI request retries. |
| `AI_INTERNAL_ENABLED` | Enable internal AI integration. |
| `AI_VISION_ENABLED` | Enable AI vision features. |
| `AI_TEXT_ENABLED` | Enable AI text features. |

## Setup and credentials

Create the OIDC client in **Authentik Admin**. For a *new* database password and frontend session secret, use:

```bash
# PostgreSQL password
openssl rand -hex 32

# Frontend Auth.js / NextAuth secret for a new instance
openssl rand -base64 33
```

Preserve existing passwords and secrets when restoring. The required format for Wardrowbe's backend `SECRET_KEY` **needs verification**; do not invent a generator. Ensure the chosen models exist in Ollama. The `migrate` container is a one-shot job and may exit successfully.

## Deploy / check

```bash
cd /home/homelab/docker/applications/wardrobe
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
