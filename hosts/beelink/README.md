# BeeLink SEi12 — Docker host

Example application host. A **sample deployment path** is `/home/homelab/docker`; configure your own storage layout and usernames before use.

**Tailscale is installed directly on the Linux host (bare metal).**

AdGuard Home handles local DNS, Caddy is the HTTPS reverse proxy, and Authentik provides SSO and application/group permissions. Authentik providers and group policies are managed in its admin interface.

## How requests reach applications

```text
        LAN devices                   Tailscale devices
             |                              |
             +------- private access -------+
                             |
                     AdGuard Home (DNS)
                     name -> host IP
                             |
               Client connects to Caddy (HTTPS)
                             |
                +------------+-------------+
                |                          |
         Native SSO app              Forward-auth app
                |                          ^
       OIDC/SAML sign-in              Caddy checks with
                |                   Authentik before proxying
                v                          |
            Authentik ---------------------+
```

Conceptual flow: DNS resolution and HTTPS are **separate client requests**. With native SSO, the application handles the Authentik sign-in flow; with forward auth, Caddy checks authorization before forwarding a request. Not every client must use AdGuard for DNS.

## Docker stacks

| Category |
| --- |
| [Applications](docker/applications/) |
| [Development services](docker/development-services/) |
| [Game servers](docker/game-servers/) |
| [Infrastructure services](docker/infrastructure-services/) |
| [Media services](docker/media-services/README.md) |
| [Monitoring services](docker/monitoring-services/) |
| [Tailscale exit nodes](docker/tailscale-exit-nodes/) |

## Shared Docker networks

Some applications use two **shared external bridge networks** so containers in different Compose projects can communicate. `external: true` means the network is created outside Compose; it does **not** mean the network is publicly accessible.

| Network | Purpose |
| --- | --- |
| `database-admin-network` | Cross-stack PostgreSQL access and database administration |
| `ai-services-network` | Ollama and applications that consume its AI API |

Create these networks **once on the Docker host**, before starting a stack that references them.

<details>
<summary><strong>Show network creation, inspection and subnet commands</strong></summary>

First inspect existing networks:

```bash
docker network ls
```

If the names do not already exist, create them:

```bash
docker network create --driver bridge database-admin-network
docker network create --driver bridge ai-services-network
```

With the [example Docker address pool](../../README.md) configured and activated, Docker automatically allocates available `/24` subnets within `10.240.0.0/16`. Otherwise, it may choose from another configured pool. Check the actual assignments:

```bash
docker network inspect --format '{{json .IPAM.Config}}' database-admin-network
docker network inspect --format '{{json .IPAM.Config}}' ai-services-network
```

To **choose a fixed subnet instead of automatic allocation**, use `--subnet` when creating a *new* network. For example, the following is an **alternative** to the first creation command above, not an extra step:

```bash
docker network create --driver bridge --subnet 10.240.10.0/24 database-admin-network
```

Use an unused subnet that doesn't overlap any existing Docker, LAN or VPN network. This example does not require fixed container IPs: containers on the same Docker network should use service names or aliases. Don't remove/recreate a network just to change its subnet while running services depend on it.

</details>

**Network separation:** Do not connect unrelated stacks to shared networks by default. Caddy uses host networking here, so a separate `public` Docker network is unnecessary. See [Docker's Compose networking guide](https://docs.docker.com/compose/how-tos/networking/) for the external-network behavior.

## Start or check a stack

For future services, use the [standard Docker Compose reference](docker-compose.yml). It is a template, **not a runnable stack**.

Follow the application's README for any prerequisites and its actual `.env`. Typical example, run **on the BeeLink**:

```bash
cd /home/homelab/docker/applications/mealie
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
docker compose logs --tail=100
```

For most other stacks, replace the `cd` path with your actual deployment location. Copy the corresponding `.env.example` to `.env` first and supply required credentials.  **Media is different:** start it from the shared `media-services/compose.yml` project. Some applications require external networks, devices, admin-side OIDC setup or existing storage; read their prerequisites before starting. WUD monitors image updates for manual approval, and service image versions stay in the Compose files.

## Docker daemon file

To inspect or edit the base Docker networking configuration on this host:

```bash
sudo nano /etc/docker/daemon.json
```

The **example** uses the `10.240.0.0/16` Docker pool with `/24` bridge networks. The [repository README](../../README.md) documents the configuration and safe validation/restart commands.
