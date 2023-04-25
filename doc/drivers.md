## Build igb_uio driver
```
cd ~/gitrepo
git clone https://github.com/daynix/dpdk-kmods.git
cd dpdk-kmods
make; sudo make install
```
### Install copies the .ko to the right place:
```
cd /usr/lib/modules/$(uname -r)/extra/dpdk
sudo ln -s /home/advaadmin/gitrepo/dpdk-kmods/linux/igb_uio/igb_uio.ko igb_uio.ko
```

## Align ice and i40e drivers

ORAN F/G Release documentation mentions the following versions for the fronthaul NIC drivers :
•	ice 1.3.2
```
wget https://downloadmirror.intel.com/30303/eng/ice-1.3.2.tar.gz
```
•	i40e 2.14.13

In other place ORAN documentation mentioned the following versions:
1. Intel® Ethernet 800 Series Linux Driver (ice) — 1.4.0 (or later)
2. Wireless Edge DDP Package version (ice_wireless_edge) — 1.3.22.101 (WRONG)
3. Intel® Ethernet 800 Series firmware version — 1.5.4.2 (or later)
4. Intel® Ethernet 800 Series NVM version — 2.4 (or later)

Note, according to Intel, ‘firmware’ means to be the same as NVM
https://www.intel.com/content/www/us/en/support/articles/000059457/ethernet-products.html

```
advaadmin@yrksrv03:~/gitrepo/6g-terafactory-ran$ sudo ethtool -i eno12399
driver: ice
version: 1.3.2
firmware-version: 3.00 0x80008943 20.5.13
```
First field is the firmware or NVM version (3.00).
Second field is the EtrackID (0x80008943).
Third field is the Combo Boot Image version (version of the BootIMG.FLB file).

### Note about Xeon-D E800

On a server with Xeon(R) D-1734NT CPU we got the following results of NVM checking:
```
adva@portwell3:~/intel/E810/Linux_x64$ sudo ./nvmupdate64e

Intel(R) Ethernet NVM Update Tool
NVMUpdate version 1.39.32.6
Copyright(C) 2013 - 2023 Intel Corporation.

Num Description                          Ver.(hex)  DevId S:B    Status
=== ================================== ============ ===== ====== ==============
01) Intel(R) Ethernet Network Adapter   4.32(4.20)   159B 00:002 Up to date
    E810-XXV-2
02) Intel(R) I210 Gigabit Network         N/A(N/A)   1533 00:004 Update not
    Connection                                                   available
03) Intel(R) Ethernet Connection          N/A(N/A)   124C 00:244 Update not
    E823-L for backplane                                         available

```
We can see that Xeon-D embedded E823-L chip is probably does not support eCPRI. We need to use a discrete E810-XXV-2 NIC.


## DPDK and patched Columbiaville driver

```
wget http://fast.dpdk.org/rel/dpdk-20.11.3.tar.gz
tar -xvf dpdk-20.11.3.tar.gz
cd dpdk-stable-20.11.3
CC=icc meson x86_64-native-linuxapp-icc/
# cd x86_64-native-linuxapp-icc; ninja; sudo ninja install
```

DPDK ice driver is in librte_net_ice.so.21.0, keep this file for a reference with the different name. Now patch Columbiaville DPDK driver (file  ice_ethdev.c ):

```
                PMD_DRV_LOG(INFO, "queue %d is binding to vect %d",
                            base_queue + i, msix_vect);
//AAA+
                // /* set ITR0 value */
                // ICE_WRITE_REG(hw, GLINT_ITR(0, msix_vect), 0x2);
        /* set ITR0 value */
        ICE_WRITE_REG(hw, GLINT_ITR(0, msix_vect), 0x10);
        /* set ITR0 value
         * Empirical configuration for optimal real time latency
         * reduced interrupt throttling to 2 ms
         * Columbiaville pre-PRQ : local patch subject to change
        */
        ICE_WRITE_REG(hw, GLINT_ITR(0, msix_vect), 0x1);
        ICE_WRITE_REG(hw, QRX_ITR(base_queue + i), QRX_ITR_NO_EXPR_M);
//AAA- 
```

```
cd x86_64-native-linuxapp-icc; ninja; sudo ninja install
```

## Wireless Edge DDP package

eCPRI parsing is introduced in Wireless Edge DDP package.
To check the DDP package version:
```
dmesg | grep -i ddp
[ 4113.361991] ice 0000:f4:00.0: The DDP package was successfully loaded: ICE Wireless Edge Package version 1.3.10.0
```

ICE OS Default Package version 1.3.4.0 is not good for us, we need to set a suggested one:

```
wget https://downloadmirror.intel.com/772044/800%20Series%20DDP%20for%20Wireless%20Edge%20Package%201.3.10.0.zip
```

We need to put the package at certain place:
```
adva@portwell3:~$ ll /lib/firmware/intel/ice/ddp/
total 1288
drwxr-xr-x 2 root root   4096 Apr 19 17:32 ./
drwxr-xr-x 3 root root   4096 Apr 17 11:27 ../
-rw-r--r-- 1 root root 577796 Jul 15  2020 ice-1.3.4.0.pkg
lrwxrwxrwx 1 root root     30 Apr 19 17:32 ice.pkg -> ice_wireless_edge-1.3.10.0.pkg*
-rwxr-xr-x 1 root root 725428 Apr 19 17:31 ice_wireless_edge-1.3.10.0.pkg*
```

**NOTE:**  *DPDK 20.11 might be not compatible with ice_wireless_edge-1.3.10.0.pkg*

