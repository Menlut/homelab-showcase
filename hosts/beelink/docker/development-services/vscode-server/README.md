# VS Code Server

Browser-based development environment.

[Compose configuration](docker-compose.yml) · [Environment variables](.env.example)

To prepare a local configuration:

```bash
cp .env.example .env
```

Fill in the required values before starting containers. `.env` is ignored by Git; **never commit populated credentials**.

## Before starting

- Web: `vscode.example.com` → `127.0.0.1:3050`; **Authentik forward auth**.
- Workspace and settings: `./workspace` and `./config`.
- Host `/dev/dri` and `IPC_LOCK` permissions are used by Compose.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `TZ` | Timezone for application timestamps and schedules. |

## Setup and credentials

Match `PUID`/`PGID` to the owner of the workspace and configuration directories. Access is controlled by the existing **Authentik forward-auth** policy; no app password is defined in this `.env`.

## Deploy / check

```bash
cd /home/homelab/docker/development-services/vscode-server
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
