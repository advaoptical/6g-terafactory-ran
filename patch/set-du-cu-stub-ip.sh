#!/bin/bash
set -x
IFNAME=ens5f0
sudo ifconfig $IFNAME:ODU "192.168.130.81"
sudo ifconfig $IFNAME:CU "192.168.130.82"
sudo ifconfig $IFNAME:RIC "192.168.130.80"

