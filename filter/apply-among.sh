#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"

## interface facing clients
CLIENT_IFACE=enp2s0

## interface facing Internet
INET_IFACE=enp1s0
INET_IP=10.0.0.254

iptables -F
iptables -t nat -F
iptables -t mangle -F
ebtables-legacy -F
ebtables-legacy -t broute -F
ebtables -F

# IPv4-only
ip -f inet rule add fwmark 1 lookup 100
ip -f inet route add local default dev enp2s0 table 100

# IPv6-only
ip -f inet6 rule add fwmark 1 lookup 100
ip -f inet6 route add local default dev enp2s0 table 100

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/conf/default/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/enp2s0/rp_filter

iptables -t mangle -N DIVERT
iptables -t mangle -A DIVERT -j MARK --set-mark 1
iptables -t mangle -A DIVERT -j ACCEPT

iptables  -t mangle -A PREROUTING -p tcp -m socket -j DIVERT

iptables  -t mangle -A PREROUTING -p tcp -d $INET_IP --dport 80 -j ACCEPT
iptables  -t mangle -A PREROUTING -p tcp --dport 80 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3129
iptables  -t mangle -A PREROUTING -p tcp --dport 443 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3130

iptables -A FORWARD -p udp --dport 443 -j REJECT --reject-with icmp-port-unreachable
iptables -A FORWARD -p udp --sport 443 -j REJECT --reject-with icmp-port-unreachable
iptables -A FORWARD -p udp --dport 80 -j REJECT --reject-with icmp-port-unreachable
iptables -A FORWARD -p udp --sport 80 -j REJECT --reject-with icmp-port-unreachable

for proto in tcp udp; do
# http
ebtables-legacy -t broute -A BROUTING \
        -i $CLIENT_IFACE -p ipv6 --ip6-proto $proto --ip6-dport 80 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $CLIENT_IFACE -p ipv4 --ip-proto $proto --ip-dport 80 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $INET_IFACE -p ipv6 --ip6-proto $proto --ip6-sport 80 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $INET_IFACE -p ipv4 --ip-proto $proto --ip-sport 80 \
        -j redirect --redirect-target DROP

# https
ebtables-legacy -t broute -A BROUTING \
        -i $CLIENT_IFACE -p ipv6 --ip6-proto $proto --ip6-dport 443 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $CLIENT_IFACE -p ipv4 --ip-proto $proto --ip-dport 443 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $INET_IFACE -p ipv6 --ip6-proto $proto --ip6-sport 443 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $INET_IFACE -p ipv4 --ip-proto $proto --ip-sport 443 \
        -j redirect --redirect-target DROP
done

if test -d /proc/sys/net/bridge/ ; then
  for i in /proc/sys/net/bridge/*
  do
    echo 0 > $i
  done
  unset i
fi

# lockdown
# ebtables-legacy -t broute -I BROUTING 1 -i $CLIENT_IFACE -j redirect --redirect-target DROP
# ebtables-legacy -t broute -I BROUTING 1 -i $CLIENT_IFACE -j redirect --redirect-target DROP

BYPASS=$( find bypass/ -not -type d -exec cat {} \; | grep : | sort | uniq | tr '\n' ',' )
BLOCK=$( find block/ -not -type d -exec cat {} \; | grep : | sort | uniq | tr '\n' ',' )


ebtables-legacy -t broute -I BROUTING 1 -i $CLIENT_IFACE --among-src $BLOCK -j redirect --redirect-target DROP
ebtables-legacy -t broute -I BROUTING 1 -i $CLIENT_IFACE --among-dst $BLOCK -j redirect --redirect-target DROP

ebtables-legacy -t broute -I BROUTING 1 -i $CLIENT_IFACE --among-src $BYPASS -j ACCEPT
ebtables-legacy -t broute -I BROUTING 1 -i $CLIENT_IFACE --among-dst $BYPASS -j ACCEPT


