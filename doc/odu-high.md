# ODU compilation with FlexRAN L1

```
cd ~/gitrepo/l2/src
mkdir wls_lib
cd wls_lib
ln -s ~/phy/wls_lib/wls_lib.h wls_lib.h
cd ..
ln -s $RTE_SDK/lib/librte_eal/include dpdk_lib
cd ~/gitrepo/l2/build/odu
make odu PHY=INTEL_L1 MACHINE=BIT64 MODE=TDD
```

We need to replace hardcoded paths in ODU l2/build/odu/makefie:
Link should use $(DIR_WIRELESS_WLS) and $(RTE_SDK)/$(RTE_TARGET)
