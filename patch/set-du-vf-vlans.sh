#!/bin/bash
set -x
IFNAME=eno12399
#O-DU
ip link set $IFNAME vf 0 mac 00:11:22:33:00:00 vlan 1 qos 0
# sudo ip link set $IFNAME vf 0 trust on
# sudo ip link set $IFNAME vf 1 spoofchk off
ip link set $IFNAME vf 1 mac 00:11:22:33:01:00 vlan 2 qos 0

