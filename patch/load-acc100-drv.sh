#!/bin/bash
set -x
modprobe uio_pci_generic

IGB_KO=igb_uio.ko
FILE=/usr/lib/modules/$(uname -r)/extra/dpdk/$IGB_KO
if test -f "$FILE"; then
    echo "$FILE exists."
else
#    mkdir -p  /usr/lib/modules/$(uname -r)/extra/dpdk
    FILE=~/gitrepo/dpdk-kmods/linux/igb_uio/$IGB_KO
fi

insmod $FILE

dpdk-devbind.py -b igb_uio 0000:ca:00.0

cd ~/gitrepo/pf-bb-config/
./pf_bb_config ACC100 -c acc100/acc100_config_pf.cfg

