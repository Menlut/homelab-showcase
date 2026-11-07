# Beszel — Host Monitoring

Beszel hub plus a host-networked Intel agent for hardware, filesystem and container metrics.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Web: `beszel.example.com` → `127.0.0.1:61208`; native Authentik SSO.
- Agent has Docker socket/device access and elevated capabilities. Treat it as privileged.
- Keep `./beszel_data`, `./beszel_agent_data` and `./beszel_socket`.

## Authentik SSO

[Authentik integration guide — Beszel](https://integrations.goauthentik.io/monitoring/beszel/). Follow the Beszel OIDC steps, including its email-verification scope mapping.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `BESZEL_AGENT_KEY` | Beszel hub-generated public key for the agent. |
| `BESZEL_AGENT_TOKEN` | Beszel hub-generated agent registration token. |

## Setup and credentials

Use **Beszel Hub → Add System** to obtain `BESZEL_AGENT_KEY` and `BESZEL_AGENT_TOKEN`. They are issued by Beszel; do not substitute random OpenSSL strings. The agent has elevated host/container access.

Before deploying, inspect the actual host's `/dev/dri`, disk devices and filesystem mounts. The Beszel example contains hardware-specific paths that may not exist on another system.

## Deploy / check

```bash
cd /home/homelab/docker/monitoring-services/beszel
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
