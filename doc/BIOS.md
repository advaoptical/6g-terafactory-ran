ORAN expects the certain BIOS setting. Specifically, we need to disable hyperthreading, set linear core numbering and enable SR-IOV.

By default, BIOS chooses assignment of odd Cores for node 0 and even ones for node 1:

```
advaadmin@yrksrv03:~$ sudo numactl --hardware
available: 2 nodes (0-1)
node 0 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54
node 0 size: 192706 MB
node 0 free: 166736 MB
node 1 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55
node 1 size: 193528 MB
node 1 free: 173786 MB
node distances:
node   0   1
  0:  10  20
  1:  20  10
```

After setting Linear enumeration the picture is different:

```
advaadmin@yrksrv03:~$ sudo numactl --hardware
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
node 0 size: 192734 MB
node 0 free: 175868 MB
node 1 cpus: 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55
node 1 size: 193499 MB
node 1 free: 175642 MB
node distances:
node   0   1
  0:  10  20
  1:  20  10

```

Here the necessary configuration steps performed on IDRAC console.

```
#check Hyperthreading
racadm get BIOS.ProcSettings.LogicalProc

#disable Hyperthreading
racadm set BIOS.ProcSettings.LogicalProc Disabled

# Set Linear core enumeration. Node0 Cores [0-27], Node1 Cores [28-55]
set BIOS.ProcSettings.MadtCoreEnumeration Linear

#enable SRIOV
set biOS.integratedDevices.sriovGlobalEnable Enabled

# Set performance profile
racadm set bios.SysProfileSettings.SysProfile Custom
racadm set BIOS.SysProfileSettings.ProcPwrPerf MaxPerf
racadm set BIOS.SysProfileSettings.ProcC1E Disabled
racadm set Bios.sysprofileSettings.proccstates Disabled

#commit the changes and reboot
racadm jobqueue create BIOS.Setup.1-1 -r pwrcycle -s TIME_NOW -e TIME_NA

# Enable SR-IOV per device
set NIC.DeviceLevelConfig.1.VirtualizationMode SRIOV
set NIC.DeviceLevelConfig.2.VirtualizationMode SRIOV
set NIC.DeviceLevelConfig.3.VirtualizationMode SRIOV
set NIC.DeviceLevelConfig.4.VirtualizationMode SRIOV
# Now commit changes and restart
racadm jobqueue create NIC.Integrated.1-1-1 -s TIME_NOW -e TIME_NA
racadm jobqueue create NIC.Integrated.1-2-1 -s TIME_NOW -e TIME_NA
racadm jobqueue create NIC.Slot.5-2-1 -s TIME_NOW -e TIME_NA
racadm jobqueue create NIC.Slot.5-1-1 -s TIME_NOW -e TIME_NA -r pwrcycle
```