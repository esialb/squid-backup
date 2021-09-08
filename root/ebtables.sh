#!/bin/bash

iptables -F
iptables -t nat -F
iptables -t mangle -F
ebtables-legacy -F
ebtables-legacy -t broute -F

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

iptables  -t mangle -A PREROUTING -p tcp --dport 80 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3129
iptables  -t mangle -A PREROUTING -p tcp --dport 443 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3130

## interface facing clients
CLIENT_IFACE=enp2s0

## interface facing Internet
INET_IFACE=enp1s0

# http
ebtables-legacy -t broute -A BROUTING \
        -i $CLIENT_IFACE -p ipv6 --ip6-proto tcp --ip6-dport 80 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $CLIENT_IFACE -p ipv4 --ip-proto tcp --ip-dport 80 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $INET_IFACE -p ipv6 --ip6-proto tcp --ip6-sport 80 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $INET_IFACE -p ipv4 --ip-proto tcp --ip-sport 80 \
        -j redirect --redirect-target DROP

# https
ebtables-legacy -t broute -A BROUTING \
        -i $CLIENT_IFACE -p ipv6 --ip6-proto tcp --ip6-dport 443 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $CLIENT_IFACE -p ipv4 --ip-proto tcp --ip-dport 443 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $INET_IFACE -p ipv6 --ip6-proto tcp --ip6-sport 443 \
        -j redirect --redirect-target DROP

ebtables-legacy -t broute -A BROUTING \
        -i $INET_IFACE -p ipv4 --ip-proto tcp --ip-sport 443 \
        -j redirect --redirect-target DROP



if test -d /proc/sys/net/bridge/ ; then
  for i in /proc/sys/net/bridge/*
  do
    echo 0 > $i
  done
  unset i
fi

