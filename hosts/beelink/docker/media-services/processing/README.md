# Processing — FileFlows

FileFlows media processing with optional Intel video acceleration.

[Compose configuration](docker-compose.yml) · [Shared environment file](../.env.example) · [Media deployment instructions](../README.md)

## What to know

- Web: `media-fileflows.example.com` → local `${FILEFLOWS_WEB_PORT}`; Authentik forward auth.
- Persistent FileFlows state: `./media-fileflowsdata`; temporary working folder: `./media-fileflowstemp`.
- Shares `${MEDIA_PATH}` with the other media components.

## Shared environment variables

Only variables relevant to this component are listed here. The [parent media README](../README.md) lists **every** variable in the shared `.env`.

| Variable | Purpose |
| --- | --- |
| `TZ` | Timezone for application timestamps and schedules. |
| `PUID` | Linux user ID for files created by the container. |
| `PGID` | Linux group ID for files created by the container. |
| `MEDIA_PATH` | Host folder containing shared media libraries/downloads. |
| `VIDEO_GID` | Host video group ID for hardware acceleration. |
| `RENDER_GID` | Host render group ID for hardware acceleration. |
| `FILEFLOWS_WEB_PORT` | Host loopback port for FileFlows. |

## Setup notes

- Check the host device/group permissions (`VIDEO_GID`, `RENDER_GID`) before enabling hardware acceleration.
- Set processing workflows in FileFlows; they are not configured by the Compose file alone.

**Deploy through [`../compose.yml`](../compose.yml), not this subfolder.**
