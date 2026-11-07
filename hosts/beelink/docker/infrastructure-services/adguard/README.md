# AdGuard Home — DNS

The homelab DNS server; runs with **host networking**.

[Compose configuration](docker-compose.yml)

## Before starting

- Dashboard: `adguard.example.com`, behind Authentik forward auth in Caddy.
- Preserve `./adguard-conf` and `./adguard-work`.
- A restart can interrupt DNS for the whole network.

## Environment variables

No `.env` file is supplied for this stack; app settings are managed in the application UI or its mounted configuration.

## Setup and credentials

AdGuard Home has no `.env` in this project. Configure DNS filters and admin credentials in the AdGuard UI / persistent configuration. Before restarting this DNS service, confirm clients have a working fallback or maintenance window.

## Custom DNS filtering rules

**EXAMPLE RULES ONLY.** These use reserved `example.com`, an illustrative LAN (`192.168.50.0/24`), an example Tailscale device IP (`100.101.102.103`), and an example Docker pool (`10.240.0.0/16`). Replace with your own routing values before configuring **AdGuard Home → Filters → Custom filtering rules**: The Tailscale `$client=100.64.0.0/10` condition matches DNS queries whose **source IP is in that range**; the A-record answer `100.101.102.103` represents **this example host**. Do not replace the client subnet with a single device IP unless you intend to restrict the rule to that device.


**Tailscale client-range clarification:** `100.64.0.0/10` is the shared IPv4 range used by Tailscale devices **across all tailnets**, not a private range assigned only to your tailnet. It is also used outside Tailscale for carrier-grade NAT. AdGuard’s `$client` condition checks only the DNS requester’s source IP; it does **not** verify Tailscale identity, tailnet membership, or authorization. Tailscale tailnets remain isolated by their routing and access policies. Restrict who can reach AdGuard DNS rather than treating this CIDR as proof of trust.

```text
! ==========================================================
! Homelab - LAN DNS
! ==========================================================
! IPv4 - LAN
||example.com^$client=192.168.50.0/24,dnstype=A,dnsrewrite=NOERROR;A;192.168.50.10
! IPv6 - LAN (Return NOERROR without an IPv6 address)
||example.com^$client=192.168.50.0/24,dnstype=AAAA,dnsrewrite=NOERROR;;
! ==========================================================
! Homelab - Tailscale DNS
! ==========================================================
! Client range: 100.64.0.0/10; example DNS answer: 100.101.102.103
! IPv4 - Tailscale
||example.com^$client=100.64.0.0/10,dnstype=A,dnsrewrite=NOERROR;A;100.101.102.103
! IPv6 - Tailscale (Return NOERROR without an IPv6 address)
||example.com^$client=100.64.0.0/10,dnstype=AAAA,dnsrewrite=NOERROR;;
! ==========================================================
! Homelab - Docker DNS
! ==========================================================
! IPv4 - Beelink Docker Networks
||example.com^$client=10.240.0.0/16,dnstype=A,dnsrewrite=NOERROR;A;192.168.50.10
! IPv6 - Return NOERROR without an IPv6 address
||example.com^$client=10.240.0.0/16,dnstype=AAAA,dnsrewrite=NOERROR;;
```

**When adding another host:** Add its Docker subnet to the **Homelab - Docker DNS** rules for both A and AAAA queries. The sample `10.240.0.0/16` rules cover only the example BeeLink Docker address pool; they do not automatically cover new machines.

## Deploy / check

```bash
cd /home/homelab/docker/infrastructure-services/adguard
docker compose config --quiet
docker compose up -d --pull never
docker compose ps
```
