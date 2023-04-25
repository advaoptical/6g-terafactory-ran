# Toolchain
For building ORAN libraries and executables, we need to install Intel OneAPI toolchain, meson+ninja and misc. packages. ORAN documentation references CentOS/RHEL, we are using Ubuntu 20.04 LTS.
Most toolchain installation steps are documented in the script [https://gitlab.rd.advaoptical.com/hyperion/oai-oran-study/-/blob/master/install-oran-toolchain.sh]. Do not run the script thought, it is for reference only. 

```
wget https://registrationcenter-download.intel.com/akdlm/irc_nas/19079/l_BaseKit_p_2023.0.0.25537_offline.sh
```
Run the installation, we will get ICX compiler. ORAN F needs ICC compiler which is part of HPC kit.

```
wget https://registrationcenter-download.intel.com/akdlm/irc_nas/19084/l_HPCKit_p_2023.0.0.25400_offline.sh
```
Run the script and select ICC.
After the installation, append the line to *.bashrc* file
```
source /opt/intel/oneapi/setvars.sh
```



