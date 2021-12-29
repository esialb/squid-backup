#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"

BRIDGE_MAC=fa:8e:b8:79:dd:d7

## interface facing clients
CLIENT_IFACE=enp2s0

## interface facing Internet
INET_IFACE=enp1s0
INET_IP=10.0.0.254

iptables -F
iptables -t nat -F
iptables -t mangle -F
ebtables -F
ebtables -t nat -F
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

iptables  -t mangle -A PREROUTING -p tcp -d $INET_IP --dport 80 -j ACCEPT
iptables  -t mangle -A PREROUTING -p tcp --dport 80 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3129
iptables  -t mangle -A PREROUTING -p tcp --dport 443 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 3130

iptables -A FORWARD -p udp --dport 443 -j REJECT --reject-with icmp-port-unreachable
iptables -A FORWARD -p udp --sport 443 -j REJECT --reject-with icmp-port-unreachable
iptables -A FORWARD -p udp --dport 80 -j REJECT --reject-with icmp-port-unreachable
iptables -A FORWARD -p udp --sport 80 -j REJECT --reject-with icmp-port-unreachable

BYPASS=$( find bypass/ -not -type d -exec cat {} \; | sed -r 's/#.*//' | grep : | sort | uniq )
BLOCK=$( find block/ -not -type d -exec cat {} \; | sed -r 's/#.*//' | grep : | sort | uniq )


for MAC in $BYPASS; do
  ebtables -t nat -A PREROUTING --src $MAC -j ACCEPT
  ebtables -t nat -A PREROUTING --dst $MAC -j ACCEPT
done

if [ -e lockdown ]; then
  ebtables -t nat -A PREROUTING -i $INET_IFACE -j DROP
  ebtables -t nat -A PREROUTING -i $CLIENT_IFACE -j DROP
else

for MAC in $BLOCK; do
  ebtables -t nat -A PREROUTING --src $MAC -j DROP
  ebtables -t nat -A PREROUTING --dst $MAC -j DROP
done

  for port in 80 443; do
    # send tcp to squid
    ebtables -t nat -A PREROUTING -i $CLIENT_IFACE -p ipv6 --ip6-proto tcp --ip6-dport $port -j dnat --to-dst $BRIDGE_MAC
    ebtables -t nat -A PREROUTING -i $CLIENT_IFACE -p ipv4 --ip-proto tcp --ip-dport $port -j dnat --to-dst $BRIDGE_MAC
    ebtables -t nat -A PREROUTING -i $INET_IFACE -p ipv6 --ip6-proto tcp --ip6-sport $port -j dnat --to-dst $BRIDGE_MAC
    ebtables -t nat -A PREROUTING -i $INET_IFACE -p ipv4 --ip-proto tcp --ip-sport $port -j dnat --to-dst $BRIDGE_MAC
    # drop udp stuff from chrome
    ebtables -t nat -A PREROUTING -i $CLIENT_IFACE -p ipv6 --ip6-proto udp --ip6-dport $port -j dnat --to-dst $BRIDGE_MAC
    ebtables -t nat -A PREROUTING -i $CLIENT_IFACE -p ipv4 --ip-proto udp --ip-dport $port -j dnat --to-dst $BRIDGE_MAC
    ebtables -t nat -A PREROUTING -i $INET_IFACE -p ipv6 --ip6-proto udp --ip6-dport $port -j dnat --to-dst $BRIDGE_MAC
    ebtables -t nat -A PREROUTING -i $INET_IFACE -p ipv4 --ip-proto udp --ip-dport $port -j dnat --to-dst $BRIDGE_MAC
  done
  
  ebtables -t nat -A PREROUTING -i $INET_IFACE -j ACCEPT
  ebtables -t nat -A PREROUTING -i $CLIENT_IFACE -j ACCEPT
  
fi

if test -d /proc/sys/net/bridge/ ; then
  for i in /proc/sys/net/bridge/*
  do
    echo 0 > $i
  done
  unset i
fi

