#/usr/bin/env sh
# Update iptables rules with a bridge IP to be able to reach the world from
# Docker containers
BRIDGE_IP="$(ip ro | grep br- | awk '{print $1}')"
/sbin/iptables -t nat -A POSTROUTING ! -o docker0 -s "${BRIDGE_IP}" -j MASQUERADE
