#!/bin/sh

set -u

: "${EXPECTED_COUNTRY:?EXPECTED_COUNTRY must be set}"

TAILSCALE_CIDR="100.64.0.0/10"
TAILSCALE_TABLE="52"
ROUTE_PRIORITY="97"

FORWARD_CHAIN="TS_GLUE_FORWARD"
NAT_CHAIN="TS_GLUE_POSTROUTING"

GLUETUN_API="http://127.0.0.1:8000"

echo "Waiting for Tailscale routing table..."

until ip route show table "${TAILSCALE_TABLE}" 2>/dev/null | grep -q "tailscale0"; do
    sleep 2
done

echo "Tailscale routing table detected"

###########################################################
# Create dedicated chains
###########################################################

iptables -N "${FORWARD_CHAIN}" 2>/dev/null || true
iptables -t nat -N "${NAT_CHAIN}" 2>/dev/null || true

###########################################################
# NAT
###########################################################

iptables -t nat -F "${NAT_CHAIN}"
iptables -t nat -A "${NAT_CHAIN}" \
    -s "${TAILSCALE_CIDR}" \
    -o tun0 \
    -j MASQUERADE

###########################################################
# Initial state: fail closed
###########################################################

iptables -F "${FORWARD_CHAIN}"
iptables -A "${FORWARD_CHAIN}" \
    -i tailscale0 \
    -j DROP

echo "Tailscale/Gluetun firewall chains initialized"
echo "Expected VPN country: ${EXPECTED_COUNTRY}"
echo "Initial state: kill switch enabled"

VPN_WAS_VALID="unknown"

###########################################################
# Continuous validation / repair
###########################################################

while true; do

    #######################################################
    # Tailscale return route
    #######################################################

    if ! ip rule show | grep -q "to ${TAILSCALE_CIDR} lookup ${TAILSCALE_TABLE}"; then

        if ip rule show | grep -q "^${ROUTE_PRIORITY}:"; then
            echo "ERROR: routing rule priority ${ROUTE_PRIORITY} is already in use"
        else
            echo "Adding Tailscale return-route rule"

            ip rule add \
                pref "${ROUTE_PRIORITY}" \
                to "${TAILSCALE_CIDR}" \
                lookup "${TAILSCALE_TABLE}"
        fi

    fi

    #######################################################
    # Validate Gluetun VPN state and exit country
    #######################################################

    VPN_STATUS="$(
        curl -fsS \
            "${GLUETUN_API}/v1/vpn/status" \
            2>/dev/null || true
    )"

    PUBLIC_IP_DATA="$(
        curl -fsS \
            "${GLUETUN_API}/v1/publicip/ip" \
            2>/dev/null || true
    )"

    if echo "${VPN_STATUS}" | grep -q '"status":"running"' &&
       echo "${PUBLIC_IP_DATA}" | grep -q "\"country\":\"${EXPECTED_COUNTRY}\""; then

        VPN_VALID="true"

    else

        VPN_VALID="false"

    fi

    #######################################################
    # Change forwarding only when validation state changes
    #######################################################

    if [ "${VPN_VALID}" != "${VPN_WAS_VALID}" ]; then

        iptables -F "${FORWARD_CHAIN}"

        if [ "${VPN_VALID}" = "true" ]; then

            echo "VPN valid - ${EXPECTED_COUNTRY} exit confirmed"
            echo "Enabling exit-node forwarding"

            # Tailscale client -> Proton VPN
            iptables -A "${FORWARD_CHAIN}" \
                -i tailscale0 \
                -o tun0 \
                -j ACCEPT

            # Proton VPN -> Tailscale client return traffic
            iptables -A "${FORWARD_CHAIN}" \
                -i tun0 \
                -o tailscale0 \
                -m conntrack \
                --ctstate RELATED,ESTABLISHED \
                -j ACCEPT

            # Anything from Tailscale not using Proton is blocked
            iptables -A "${FORWARD_CHAIN}" \
                -i tailscale0 \
                -j DROP

        else

            echo "VPN invalid - stopped, unreachable, or wrong country"
            echo "Enabling kill switch"

            # Fail closed:
            # no Tailscale-forwarded internet unless the VPN is valid
            iptables -A "${FORWARD_CHAIN}" \
                -i tailscale0 \
                -j DROP

        fi

        VPN_WAS_VALID="${VPN_VALID}"
    fi

    #######################################################
    # Ensure forwarding jump is first
    #######################################################

    FIRST_FORWARD="$(
        iptables -L FORWARD \
            -n \
            --line-numbers \
            2>/dev/null |
        awk '$1 == "1" {print $2; exit}'
    )"

    if [ "${FIRST_FORWARD:-}" != "${FORWARD_CHAIN}" ]; then

        echo "Repairing FORWARD chain ordering"

        while iptables -C FORWARD -j "${FORWARD_CHAIN}" 2>/dev/null; do
            iptables -D FORWARD -j "${FORWARD_CHAIN}"
        done

        iptables -I FORWARD 1 -j "${FORWARD_CHAIN}"
    fi

    #######################################################
    # Ensure NAT jump is first
    #######################################################

    FIRST_NAT="$(
        iptables -t nat \
            -L POSTROUTING \
            -n \
            --line-numbers \
            2>/dev/null |
        awk '$1 == "1" {print $2; exit}'
    )"

    if [ "${FIRST_NAT:-}" != "${NAT_CHAIN}" ]; then

        echo "Repairing POSTROUTING chain ordering"

        while iptables -t nat \
            -C POSTROUTING \
            -j "${NAT_CHAIN}" \
            2>/dev/null; do

            iptables -t nat \
                -D POSTROUTING \
                -j "${NAT_CHAIN}"
        done

        iptables -t nat \
            -I POSTROUTING 1 \
            -j "${NAT_CHAIN}"
    fi

    sleep 5

done