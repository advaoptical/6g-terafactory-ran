# Linux environments
## Disable Ubuntu unattended upgrades

```
sudo vi /etc/apt/apt.conf.d/20auto-upgrades
sudo apt remove unattended-upgrades
```
## Enable sudo without password
It is extremely convenient feature because we might need sudo from 5 separated terminal sessions. 
Edit the sudoers file and add the following line to the END of the file (if not at the end it can be nullified by later entries):


```
sudo visudo
...
advaadmin ALL=NOPASSWD: ALL
``` 
## Disable system sleep and ModemManager
```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo systemctl stop ModemManager; sudo systemctl disable ModemManager

```

## Linux command line

We modify grub to execute the proper Linux boot command:
```
sudo vi /etc/default/grub
...
GRUB_CMDLINE_LINUX="processor.max_cstate=1 intel_idle.max_cstate=0 intel_pstate=disable idle=poll default_hugepagesz=1G hugepagesz=1G hugepages=32 intel_iommu=on iommu=pt selinux=0 enforcing=0 nmi_watchdog=0 audit=0 mce=off kthread_cpus=0 irqaffinity=0 isolcpus=1-19 intel_pstate=disable nosoftlockup nohz=on nohz_full=1-19 rcu_nocbs=1-19"
...
sudo update-grub
```
For serial console we need to add it to GRUB_CMDLINE_LINUX
```
console=tty0 console=ttyS0,115200n8
```
## Environmental variables and sudo alias

Add the following variables to ~/.bashrc file
```
alias sudo='sudo -E PATH="$PATH" HOME="$HOME" LD_LIBRARY_PATH="$LD_LIBRARY_PATH"'

source /opt/intel/oneapi/setvars.sh
export PATH=$PATH:/opt/intel/oneapi/compiler/latest/linux/bin
export RTE_TARGET=x86_64-native-linuxapp-icc
export RTE_SDK=~/dpdk-stable-20.11.3
export WIRELESS_SDK_TOOLCHAIN=icc
export SDK_BUILD=build-avx512-icc
export WIRELESS_SDK_STANDARD=5gnr
source ~/phy/setupenv.sh
```

## Network interfaces
```
advaadmin@yrksrv03:~$ cat /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  ethernets:
    #E810-XXV
    eno12399:
      dhcp4: no
      addresses:
      - 10.10.0.1/24
      virtual-function-count: 2
    eno12409:
      dhcp4: no
    eno8303:
      addresses:
      - 10.100.2.31/24
      gateway4: 10.100.2.1
      nameservers:
        addresses:
        - 192.168.179.23
        - 8.8.8.8
        - 8.8.4.4
        search: []
    eno8403:
      dhcp4: no
    ens5f0:
      dhcp4: no
    ens5f1:
      dhcp4: no
  version: 2
```

## PTP

By default, both ptp4l and phc2sys services have log level 6 (LOG_INFO). It is too verbose, we need to change  it to 4 (LOG_WARNING)
We configure ptp4l and pch2sys services:
```
advaadmin@yrksrv03:~$ cat /lib/systemd/system/ptp4l.service
[Unit]
Description=Precision Time Protocol (PTP) service
Documentation=man:ptp4l

[Service]
Type=simple
ExecStart=/usr/sbin/ptp4l -f /etc/linuxptp/ptp4l.conf -i eno8403

[Install]
WantedBy=multi-user.target

In /etc/linuxptp/ptp4l.conf set
domainNumber            24
..
network_transport       L2
..
logging_level                        4

advaadmin@yrksrv03:~$ systemctl status phc2sys
● phc2sys.service - Synchronize system clock or PTP hardware clock (PHC)
     Loaded: loaded (/lib/systemd/system/phc2sys.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-03-03 11:17:51 UTC; 1 day 21h ago
       Docs: man:phc2sys
   Main PID: 11335 (phc2sys)
      Tasks: 1 (limit: 423974)
     Memory: 452.0K
     CGroup: /system.slice/phc2sys.service
             └─11335 /usr/sbin/phc2sys -w -s eno8403 -r -n 24 -l 4

Mar 05 09:05:41 yrksrv03 phc2sys[11335]: [243542.424] CLOCK_REALTIME phc offset         6 s2 freq  +27918 delay   26>
Mar 05 09:05:42 yrksrv03 phc2sys[11335]: [243543.425] CLOCK_REALTIME phc offset       -20 s2 freq  +27894 delay   25>
Mar 05 09:05:43 yrksrv03 phc2sys[11335]: [243544.425] CLOCK_REALTIME phc offset        19 s2 freq  +27927 delay   25>
```

To get the status of ptp4l we use pmc (PTP Management Client):

```
sudo pmc -u -b 0 'GET CURRENT_DATA_SET' -d 4
adva@portwell2:~$ sudo pmc -u -b 0 'GET CURRENT_DATA_SET' -d 4
sending: GET CURRENT_DATA_SET
        00e0ed.fffe.2bca46-0 seq 0 RESPONSE MANAGEMENT CURRENT_DATA_SET
                stepsRemoved     1
                offsetFromMaster 2.0
                meanPathDelay    262.0

adva@portwell2:~$ sudo pmc -u -b 0 'GET TIME_STATUS_NP' -d 4
sending: GET TIME_STATUS_NP
        00e0ed.fffe.2bca46-0 seq 0 RESPONSE MANAGEMENT TIME_STATUS_NP
                master_offset              -5
                ingress_time               1679561896595600333
                cumulativeScaledRateOffset +0.000000000
                scaledLastGmPhaseChange    0
                gmTimeBaseIndicator        0
                lastGmPhaseChange          0x0000'0000000000000000.0000
                gmPresent                  true
                gmIdentity                 0080ea.c42c.c00000
```
*offsetFromMaster* and *master_offset* are the last measured offset of the clock from the master in ```nanoseconds```.


