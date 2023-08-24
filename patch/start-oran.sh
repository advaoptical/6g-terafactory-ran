#!/bin/bash
set -x
./set-du-vf-vlans.sh
./bind-fhi-vfio-pci.sh
./load-acc100-drv.sh
./set-du-cu-stub-ip.sh
./start-l1-xran.sh
