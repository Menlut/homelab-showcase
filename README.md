# Homelab Infrastructure — Showcase

Sanitized Docker Compose examples and concise setup notes, organized by host. **This is not a production backup or a turnkey deployment.** Replace example domains, paths, image references, secrets and network allocations before use.

## Technologies and practices

| Area | Tools and approach |
| --- | --- |
| Linux | Host administration, resource controls and permissions |
| Containers | Docker Compose, pinned images, healthchecks and persistent volumes |
| Networking | Docker bridges, local DNS, HTTPS reverse proxy and routing |
| Identity | Authentik with native OIDC/SAML or Caddy forward authentication |
| Private access | Tailscale instead of inbound router port forwarding |
| Data services | PostgreSQL, Redis and database administration |
| Monitoring | Beszel, Uptime Kuma, Glances and WUD |
| AI and development | Ollama and browser-based VS Code |
| Automation | Git-tracked configuration, maintenance scripts and update review |

## Authentication

Prefer applications with **native Authentik SSO** (OIDC/SAML). Use **Authentik forward authentication** through Caddy when native integration is unavailable and the application supports proxy authentication.

## Remote access

Use **Tailscale** for private remote access; other private-access tools (such as Twingate) could be considered later. The design does **not** rely on opening inbound router ports for remote access.

| Example host | Tailscale installation |
| --- | --- |
| [BeeLink SEi12](hosts/beelink/README.md) | Installed on Linux directly (not the example Docker exit-node stacks) |

## Host inventory

| Host | Purpose | Example Docker pool | Configurations |
| --- | --- | --- | --- |
| BeeLink SEi12 | Application and infrastructure host | `10.240.0.0/16` | [Host overview](hosts/beelink/README.md) |

Future hosts should use **distinct, nonoverlapping** RFC1918 blocks. The sample convention is one `/16` pool per host and `/24` per dynamically allocated Docker bridge network. Future illustrative pools: `10.241.0.0/16`, `10.242.0.0/16`. Check for conflicts with LAN/VPN networks; these are **examples**, not a live allocation registry.

## Docker network model

| Type | How it is managed | Example |
| --- | --- | --- |
| Compose-managed bridge | Created automatically for an individual project | A stack's default network |
| Shared external bridge | Created once on the Docker host and referenced by several Compose projects | `database-admin-network`, `ai-services-network` |
| Host networking | Container uses the Linux host network stack | Caddy, AdGuard Home |

**`external: true` does not mean public internet access.** It tells Compose to use a network that already exists. The two shared bridges connect only services that need cross-stack communication; there is no separate internet-facing Docker network in this example. Creation and inspection commands are in the [BeeLink host guide](hosts/beelink/README.md).

## Example IP addresses and host networking

**All host-specific LAN, Tailscale and Docker IP addresses in this public repository have been replaced with illustrative values.** They are not the real addresses of the original homelab. The examples include `192.168.50.0/24` for the LAN, `192.168.50.10` for the LAN host, `100.101.102.103` for a Tailscale device and `10.240.0.0/16` for the Docker pool. Replace them with the networks and IP addresses actually assigned in your environment. The standard Tailscale range `100.64.0.0/10` and loopback `127.0.0.1` are intentionally left intact because they are not host-specific identifiers. The `100.64.0.0/10` subnet matches **Tailscale client addresses** in access rules; `100.101.102.103` is the **example IP of one Tailscale host** and is used as the DNS rewrite destination. They are different purposes, not conflicting values.

<details>
<summary><strong>Show commands to discover LAN and Tailscale IPs</strong></summary>

Run these commands **on your Linux host** to find its current IPv4 interface addresses, default route and on-link networks:

```bash
ip -4 -brief addr show
ip -4 route show default
ip -4 route show scope link
```

To see which source IP the host would normally use for outgoing traffic (often its LAN address), run:

```bash
ip -4 route get 1.1.1.1
```

If Tailscale is installed and connected, find **that host's** Tailscale IPv4 address with:

```bash
tailscale ip -4
tailscale status
```

</details>

Tailscale IPs are not issued by your LAN router. Do not confuse them with your DHCP-assigned LAN IPs. For a long-lived homelab, **reserve each important host's LAN IP address through the router's DHCP reservation feature** (using the network interface's MAC address), or manage a suitable static address consistently. Stable LAN addresses help keep AdGuard DNS rewrites, reverse-proxy upstreams and other host references correct. If the router or subnet changes, update the DNS and network examples too.

## Docker default-address-pools example

The example host reserves `10.240.0.0/16` for newly created Docker bridges, assigning `/24` networks. This does not renumber existing networks.

<details>
<summary><strong>Show daemon.json example, validation and activation commands</strong></summary>

On the Docker host, edit `/etc/docker/daemon.json`:

```json
{
  "default-address-pools": [
    { "base": "10.240.0.0/16", "size": 24 }
  ]
}
```

```bash
sudo install -d -m 0755 /etc/docker
# Inspect and back up an existing file; preserve unrelated daemon settings.
sudo nano /etc/docker/daemon.json
sudo python3 -m json.tool /etc/docker/daemon.json
sudo dockerd --validate --config-file /etc/docker/daemon.json
```

A Docker restart applies the change but can interrupt hosted services. Perform it only during planned maintenance:

```bash
sudo systemctl restart docker
docker info --format '{{json .DefaultAddressPools}}'
```

</details>

## Using these public examples safely

The public repository is a **reference**, not a working copy of the private homelab. Its addresses, domains, directories and custom image references are placeholders. Before deploying a stack, adapt its Compose file, reverse-proxy routes, Docker networks and storage locations to your own host.

- Copy `.env.example` to a local `.env`, then supply credentials there. Do not commit the populated file.
- **Never publish:** passwords, API tokens, private certificates or SSH keys, production databases, logs, backups, or deployment-specific identity and network settings.
- Review privileged features before use: Docker socket access, host networking, VPN routing and device mounts.
- The example [Caddyfile](hosts/beelink/docker/infrastructure-services/caddy/Caddyfile) contains illustrative routes only; the private routing configuration is not published.
- Some artifacts, including the Valheim RCON plugin DLL, are intentionally excluded and must be obtained separately.

`.gitignore` provides basic protection against accidentally staging runtime files, but **does not protect files already tracked by Git**. Check staged content and history for sensitive values before publishing.

## License

The [MIT License](LICENSE) covers original material in this repository. Third-party projects, images, plugins and bundled dependencies retain their own licenses.

## Official GitHub sources for container projects

<details>
<summary><strong>Show official project links (33 projects)</strong></summary>

Each project is listed once even if its image appears in several Compose stacks. For LinuxServer images, links point to the actual container-maintainer repositories; other links point to the upstream application source.

| Project / image | GitHub |
| --- | --- |
| AdGuard Home | [GitHub](https://github.com/AdguardTeam/AdGuardHome) |
| Authentik | [GitHub](https://github.com/goauthentik/authentik) |
| Bazarr — LinuxServer image | [GitHub](https://github.com/linuxserver/docker-bazarr) |
| Beszel (hub and agent) | [GitHub](https://github.com/henrygd/beszel) |
| Caddy | [GitHub](https://github.com/caddyserver/caddy) |
| FileFlows | [GitHub](https://github.com/FreekingDean/FileFlows) |
| Glances | [GitHub](https://github.com/nicolargo/glances) |
| Gluetun | [GitHub](https://github.com/passteque/gluetun) |
| Gluetun Web UI | [GitHub](https://github.com/Sir-Scuzza/gluetun-webui) |
| Jellyfin — LinuxServer image | [GitHub](https://github.com/linuxserver/docker-jellyfin) |
| Mealie | [GitHub](https://github.com/mealie-recipes/mealie) |
| Netshoot | [GitHub](https://github.com/nicolaka/netshoot) |
| Ollama | [GitHub](https://github.com/ollama/ollama) |
| pgAdmin 4 | [GitHub](https://github.com/pgadmin-org/pgadmin4) |
| Portainer | [GitHub](https://github.com/portainer/portainer) |
| PostgreSQL | [GitHub](https://github.com/postgres/postgres) |
| Prowlarr — LinuxServer image | [GitHub](https://github.com/linuxserver/docker-prowlarr) |
| Python | [GitHub](https://github.com/python/cpython) |
| qBittorrent — LinuxServer image | [GitHub](https://github.com/linuxserver/docker-qbittorrent) |
| qBittorrent port sync for Gluetun | [GitHub](https://github.com/mjmeli/qbittorrent-port-forward-gluetun-server) |
| Radarr — LinuxServer image | [GitHub](https://github.com/linuxserver/docker-radarr) |
| Redis | [GitHub](https://github.com/redis/redis) |
| Seerr | [GitHub](https://github.com/seerr-team/seerr) |
| Sonarr — LinuxServer image | [GitHub](https://github.com/linuxserver/docker-sonarr) |
| Speedtest Tracker — LinuxServer image | [GitHub](https://github.com/linuxserver/docker-speedtest-tracker) |
| Stirling PDF | [GitHub](https://github.com/Stirling-Tools/Stirling-PDF) |
| Tailscale | [GitHub](https://github.com/tailscale/tailscale) |
| Uptime Kuma | [GitHub](https://github.com/louislam/uptime-kuma) |
| Valheim Server | [GitHub](https://github.com/community-valheim-tools/valheim-server-docker) |
| Vikinger Panel | [GitHub](https://github.com/viniciuspetrachin/vikinger-panel) |
| VS Code — LinuxServer image | [GitHub](https://github.com/linuxserver/docker-vscode) |
| Wardrowbe | [GitHub](https://github.com/Anyesh/wardrowbe) |
| WUD (Whats Up Docker) | [GitHub](https://github.com/getwud/wud) |

The sample `ghcr.io/example-user/caddy-cloudflare` image and `your-registry/your-app` template image are **placeholders**, not published images and therefore have no matching source repository here. For custom Caddy builds, refer to the [official Caddy Docker image](https://github.com/caddyserver/caddy-docker) and [Cloudflare DNS plugin](https://github.com/caddy-dns/cloudflare).

</details>
