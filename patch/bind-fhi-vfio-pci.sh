#!/bin/bash
set -x
modprobe vfio-pci
dpdk-devbind.py -b vfio-pci 0000:31:01.0 0000:31:01.1
