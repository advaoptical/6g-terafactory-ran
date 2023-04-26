# L1 lcore allocation

ORAN DU-low and FAPI TM are DPDK applications. Their lcore allocation is specified in several configuration files. Generally we should avoid sharing a lcore between tasks/threads. 

| App | File | variable | Description | Yrksrv3 | Bntl |
| --- | ---- | -------- | ----------- | ------- | ---- |
| ALL | /proc/cmdline | isolcpus= | Isolate CPUs from the kernel schedule | 1-19 | 
| L1 | xrancfg_sub6.xml  | xRANThread | core where the XRAN polling function is pinned | 5 0x1000 | 20 | 
| L1 | xrancfg_sub6.xml  | xRANWorker | core mask for XRAN Packets Worker | 0x20000 18 | 0x40000 19 |
| L1 | phycfg_xran.xml  | Threads.systemThread | System Threads (Single core id) | 2 | 0 |
| L1 | phycfg_xran.xml  | Threads.timerThread | Timer Thread (Single core id value) | 1 | 0 |
| L1 | phycfg_xran.xml  | Threads.FpgaDriverCpuInfo | FPGA for LDPC Thread | 3 | 3 |
| L1 | phycfg_xran.xml  | Threads.FrontHaulCpuInfo | FPGA for Front Haul (FFT / IFFT) | 3 | 3 |
| L1 | phycfg_xran.xml  | Threads.radioDpdkMaster | DPDK Radio Master Thread | 3 | 0 |
| L1 | phycfg_xran.xml  | BbuPoolConfig.BbuPoolThreadDefault_0_63 | BBUPool Worker Thread Cores (Bit mask of all cores that are used for BBU Pool) | 0xFFE0 (5-15) | 0x15554 (2,4,6,8,10,12,14,16) |
| L1 | phycfg_xran.xml  | BbuPoolConfig.BbuPoolThreadUrllc | URLLC Processing Thread (Bit mask) | 0x8000 (16) | 0x100 (9) |
| FAPI TM | oran_5g_fapi.cfg | MAC2PHY_WORKER. core_id | 18
| FAPI TM | ran_5g_fapi.cfg | PHY2MAC_WORKER. core_id | 19
| FAPI TM | oran_5g_fapi.cfg | URLLC_WORKER. core_id | 17
