# Ubuntu RT patch

Some extra tools needed for building the kernel 5.4.78-rt44-custom

```
sudo apt install dwarves
sudo apt-get -f install debhelper
```
Follow the instructions from https://docs.ros.org/en/foxy/Tutorials/Miscellaneous/Building-Realtime-rt_preempt-kernel-for-ROS-2.html


All is correct with small changes:

1. When running ```make menuconfig``` we *might* need to select ```-> General Setup.Embedded``` to enable “Expert” mode, allowing full preemptive RT mode.

2. Before “make” step we need to comment out the lines CONFIG_SYSTEM_TRUSTED_KEY and CONFIG_MODULE_SIG_KEY in .config file.
As result, we will just use a random one-time cert.

3. make arguments are different:

~~make -j `nproc` deb-pkg~~
```
make -j `getconf _NPROCESSORS_ONLN` bindeb-pkg LOCALVERSION=-custom
```
Hit Enter to all the prompts.

## ICE driver patching

It turned out that RT kernel must have CONFIG_NET_RX_BUSY_POLL disabled, and an official Intel ICE driver does not support this. As result, the linkage is failed because RT kernel does not have ```napi_busy_loop``` API/ABI.
To solve the issue, we need to patch ICE driver.
For instance, 1.3.2 version (other versions also need to be patched):
```
adva@portwell2:~/gitrepo/ice-1.3.2/src$ cat ice_xsk_rt_kernel_patch
--- ice_xsk.c   2023-03-26 19:54:08.996072299 +0300
+++ ice_xsk.c.org       2023-03-26 19:52:16.821049910 +0300
@@ -1237,8 +1237,7 @@
        if (!napi_if_scheduled_mark_missed(&q_vector->napi)) {
                if (ice_ring_ch_enabled(vsi->rx_rings[queue_id]) &&
                    !ice_vsi_pkt_inspect_opt_ena(vsi))
-                       //AAA napi_busy_loop(q_vector->napi.napi_id, NULL, NULL);
-                        printk(KERN_ERR "AAA napi_busy_loop\n");
+                       napi_busy_loop(q_vector->napi.napi_id, NULL, NULL);
                else
                        ice_trigger_sw_intr(&vsi->back->hw, q_vector);
        }

```

This patch has been created by the following command:
```
diff -u ice_xsk.c ice_xsk.c.org > ice_xsk_rt_kernel_patch
```
To apply it
```
patch ice_xsk.c < ice_xsk_rt_kernel_patch
```

## Misc boot tips

Ubuntu does not have *grubby* by default, so the managing of boot is less convenient than RH/CentOS.

To write all the current kernels you have on a file.
```
dpkg --list | egrep -i --color 'linux-image|linux-headers|linux-modules' | awk '{ print $2 }' > kernels.txt
```

Filter your currently used kernel out of the file using grep.
```
grep -v $(uname -r) kernels.txt > kernels_to_delete.txt
```

Edit the file – do not remove current linux headers!
Delete all the unused kernels in one go.
```
cat kernels_to_delete.txt | xargs sudo apt purge -y
```

Reboot into a specific kernel, which version number and type could be get from ```ls /boot | grep vmlinuz``` command execution.
```
    kernel="5.3.0-40-generic"
    kernlist="$(grep -i "menuentry '" /boot/grub/grub.cfg|sed -r "s|--class .*$||g")"
    printf "%s$kernlist\n" | logger
    menuline="$(printf "%s$kernlist\n"|grep -ne $kernel | grep -v recovery | cut -f1 -d":")"
    menunum="$(($menuline-2))"
    grub-reboot "1>$menunum"
    echo "The next grub's menu entry will be choosen after the reboot:\n 1>$menunum" | logger

    reboot
```




