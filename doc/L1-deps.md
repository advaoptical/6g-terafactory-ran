# L1 dependencies

## libcrypto

One of unpleasant ABI dependencies is libcrypto.so.10, part of Open SSL. The challenge is that the expected ABI is far behind one installed on Ubuntu.  To solve this dependency, we need to get a specific old version of Open SSL and to build libcrypto.so
wget https://ftp.openssl.org/source/old/1.0.2/openssl-1.0.2k.tar.gz
tar -xvf openssl-1.0.2k.tar.gz
cd openssl-1.0.2k; sudo ./config -fPIC -shared; make
sudo ln -s ~/openssl-1.0.2k/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.10

## libpcap

After *libpcap* installation, we might need to create the symbolic link:
```
sudo ln -s /usr/lib/x86_64-linux-gnu/libpcap.so.0.8 /usr/lib/x86_64-linux-gnu/libpcap.so.1
```

## RT verification

Another check recommended by Intel is thread switching time, which should be closed to RT.
```
sudo cyclictest -m -p95 -d0 -a 1-16 -t 16
```

## Hugapages release

L1 Application does not release hugepages on exit, so we need to release it manually:
```
advaadmin@yrksrv03:~$ cat release-hugepages.sh
#!/bin/bash
set -x
sudo rm -f /dev/hugepages/*
```