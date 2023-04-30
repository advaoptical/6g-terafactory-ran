# L1-L2 lcore allocation (under constriction)

ORAN DU-low, FAPI TM and ODU-high applications use xran library based on DPDK framework. The cores for DPDK threads are passed as an argument to *rte_eal_init* call. Their lcore allocation is specified in several configuration files and hardcoded (ODU-high). Generally we should avoid sharing a lcore between tasks/threads.
For example L1 application the rte_eal_init call is like this:
```
total cores 56 c_mask 0x000000000000c0004 
core 19 [id] 
system_core 2 [id] 
pkt_proc_core 0x000000000000400          00 [mask] 
pkt_aux_core 0 [id] 
timing_core 19 [id]
xran_ethdi_init_dpdk_io: Calling rte_eal_init:gnb0 -c 0x000000000000c0004 -n2 --iova-mode=pa --socket-mem          =16384,0 --socket-limit=16384,0 --proc-type=auto --file-prefix gnb0 -a0000:00:00.0 -a0000:ca:00.0
```

The below Table reflects ongoing experiments and will be updated.

| App | File | variable | Description | value | Hex | Bntl |
| --- | ---- | -------- | ----------- | ----- | --- | ---- |
| ALL | /proc/cmdline | isolcpus= | Isolate CPUs from the kernel schedule for real time tasks | 1-19 | 0x8FFFE
| L1 | xrancfg_sub6.xml  | xRANThread | core where the XRAN polling function is pinned | 19 | 0x80000 | 20 | 
| L1 | xrancfg_sub6.xml  | xRANWorker | core mask for XRAN Packets Worker | 18 | 0x40000 | 19 |
| L1 | phycfg_xran.xml  | Threads.systemThread | System Threads (Single core id) | 2 | 0x0004 | 0
| L1 | phycfg_xran.xml  | Threads.timerThread | Timer Thread (Single core id value) | 0 | 0x0001 | 0
| L1 | phycfg_xran.xml  | Threads.FpgaDriverCpuInfo | FPGA for LDPC Thread | 3 | 0x0008 | 3 |
| L1 | phycfg_xran.xml  | Threads.FrontHaulCpuInfo | FPGA for Front Haul (FFT / IFFT) | 3 | 0x0008 | 3 |
| L1 | phycfg_xran.xml  | Threads.radioDpdkMaster | DPDK Radio Master Thread | 2 | 0x0004 | 0 |
| L1 | phycfg_xran.xml  | BbuPoolConfig.BbuPoolThreadDefault_0_63 | BBUPool Worker Thread Cores (Bit mask of all cores that are used for BBU Pool) | 4-7 | 0x00F0 |  2,4,6,8,10,12,14,16 0x15554 |
| L1 | phycfg_xran.xml  | BbuPoolConfig.BbuPoolThreadUrllc | URLLC Processing Thread (Bit mask) | 8 | 0x100 | 0x0100 (9) |
| FAPI TM | oran_5g_fapi.cfg | MAC2PHY_WORKER. core_id | - | 10 | 0x0400 
| FAPI TM | ran_5g_fapi.cfg | PHY2MAC_WORKER. core_id | - | 11 | 0x800
| FAPI TM | oran_5g_fapi.cfg | URLLC_WORKER. core_id | - | 12 | 0x1000
| ODU | mt_ss.c | rte_eal_init | WLS | 13,14 | 0x6000 |
